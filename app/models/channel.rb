require 'digest/sha2'

class Channel < ActiveRecord::Base
  include ChannelMetadata
  include ChannelSerialization

  # Channel directions
  Incoming = 1
  Outgoing = 2
  Bidirectional = Incoming + Outgoing

  belongs_to :account
  belongs_to :application

  has_many :ao_messages, :conditions => proc { { :account_id => self.account_id } }
  has_many :at_messages, :conditions => proc { { :account_id => self.account_id } }
  has_many :address_sources

  serialize :configuration, Hash
  serialize :restrictions
  serialize :ao_rules
  serialize :at_rules

  attr_accessor :throttle_opt

  validates_presence_of :name, :protocol, :kind, :account
  validates_format_of :name, :with => /^[a-zA-Z0-9\-_]+$/, :message => "can only contain alphanumeric characters, '_' or '-' (no spaces allowed)", :unless => proc {|c| c.name.blank?}
  validates_uniqueness_of :name, :scope => :account_id, :message => 'has already been used by another channel in the account'
  validates_inclusion_of :direction, :in => [Incoming, Outgoing, Bidirectional], :message => "must be 'incoming', 'outgoing' or 'bidirectional'"
  validates_numericality_of :throttle, :allow_nil => true, :only_integer => true, :greater_than_or_equal_to => 0
  validates_numericality_of :ao_cost, :greater_than_or_equal_to => 0, :allow_nil => true
  validates_numericality_of :at_cost, :greater_than_or_equal_to => 0, :allow_nil => true

  scope :enabled, where(:enabled => true)
  scope :disabled, where(:enabled => false)
  scope :outgoing, where(:direction => [Outgoing, Bidirectional])
  scope :incoming, where(:direction => [Incoming, Bidirectional])

  after_update :reroute_messages, :if => lambda { enabled_changed? && !enabled }

  def self.after_enabled(method, options = {})
    after_update method, options.merge(:if => lambda { (enabled_changed? && enabled) || (paused_changed? && !paused) })
  end

  def self.after_changed(method, options = {})
    after_update method, options.merge(:if => lambda { changed? && !enabled_changed? && !paused_changed? })
  end

  def self.after_disabled(method, options = {})
    after_update method, options.merge(:if => lambda { (enabled_changed? && !enabled) || (paused_changed? && paused) })
  end

  def self.sort_candidate!(chans)
    chans.each{|x| x.configuration[:_p] = (x.priority || 100) + rand}
    chans.sort! do |x, y|
      result = x.configuration[:_p].floor <=> y.configuration[:_p].floor
      result = ((x.paused ? 1 : 0) <=> (y.paused ? 1 : 0)) if result == 0
      result = x.configuration[:_p] <=> y.configuration[:_p] if result == 0
      result
    end
  end

  def incoming?
    (direction & Incoming) != 0
  end

  def outgoing?
    (direction & Outgoing) != 0
  end

  def route_ao(msg, via_interface, options = {})
    simulate = options[:simulate]
    dont_save = options[:dont_save]

    ThreadLocalLogger << "Message routed to channel '#{name}'"

    # Assign cost
    msg.cost = ao_cost if ao_cost.present?

    # Apply AO Rules
    apply_ao_rules msg

    # Discard the message if the rules canceled the message
    if msg.state == 'canceled'
      msg.channel = self
      msg.state = 'canceled'
      msg.save! unless simulate || dont_save

      ThreadLocalLogger << "Message was canceled by channel ao rules."
      logger.info :application_id => msg.application_id, :channel_id => self.id, :ao_message_id => msg.id, :message => ThreadLocalLogger.result unless simulate
      return
    end

    # Discard the message if the 'from' and 'to' are the same
    if msg.from == msg.to
      msg.channel = self
      msg.state = 'failed'
      msg.save! unless simulate || dont_save

      ThreadLocalLogger << "Message 'from' and 'to' addresses are the same. The message will be discarded."
      logger.warning :application_id => msg.application_id, :channel_id => self.id, :ao_message_id => msg.id, :message => ThreadLocalLogger.result unless simulate
      return
    end

    # Discard message if the 'to' address is not valid
    if not msg.to.valid_address?
      msg.state = 'failed'
      msg.save! unless simulate || dont_save

      ThreadLocalLogger << "Message 'to' address is invalid. The message will be discarded."
      logger.warning :application_id => msg.application_id, :channel_id => self.id, :ao_message_id => msg.id, :message => ThreadLocalLogger.result unless simulate
      return
    end

    # Save the message
    msg.channel = self
    msg.state = 'queued'
    msg.save! unless simulate || dont_save

    unless simulate
      logger.info :application_id => msg.application_id, :channel_id => self.id, :ao_message_id => msg.id, :message => ThreadLocalLogger.result

      # Handle the message
      handle msg
    end
  end

  def apply_ao_rules(msg)
    ao_routing_res = RulesEngine.apply(msg.rules_context, self.ao_rules)
    if ao_routing_res.present?
      ThreadLocalLogger << "Applying channel ao rules..."
      msg.original = msg.merge ao_routing_res
    end
  end

  def can_route_ao?(msg)
    # Check that each custom attribute is present in this channel's restrictions
    all_restrictions = augmented_restrictions
    msg.custom_attributes.each_multivalue do |key, values|
      channel_values = all_restrictions[key]
      next unless channel_values.present?

      channel_values = [channel_values] unless channel_values.kind_of? Array

      return false unless values.any?{|v| channel_values.include? v}
    end

    all_restrictions.each_multivalue do |key, values|
      next if values.include? ''
      return false unless msg.custom_attributes.has_key? key
    end

    return true
  end

  def connected=(value)
    if value
      Rails.cache.write connected_cache_key, 1, :expires_in => 2.minutes
    else
      Rails.cache.delete connected_cache_key
    end
  end

  def connected?
    !!(Rails.cache.read connected_cache_key)
  end

  def self.connected(channels)
    keys = channels.select(&:has_connection?).map(&:connected_cache_key)
    hash = Rails.cache.read_multi *keys
    Hash[hash.map{|k, v| [k[/\d+/].to_i, v]}]
  end

  def configuration
    self[:configuration] ||= {}
  end

  def restrictions
    self[:restrictions] ||= ActiveSupport::OrderedHash.new
  end

  def augmented_restrictions
    restrictions
  end

  def route_at(msg)
    account.route_at msg, self
  end

  def alert(message)
    return if account.alert_emails.blank?

    logger.error :channel_id => self.id, :message => message
    AlertMailer.error(account, "Error in account #{account.name}, channel #{self.name}", message).deliver
  end

  def has_connection?
    false
  end

  def direction=(value)
    if value.kind_of? String
      if value.integer?
        self[:direction] = value.to_i
      else
        self[:direction] = Channel.direction_from_text value
      end
    else
      self[:direction] = value
    end
  end

  def direction_text
    case direction
    when Incoming then 'incoming'
    when Outgoing then 'outgoing'
    when Bidirectional then 'bidirectional'
    else 'unknown'
    end
  end

  def self.direction_from_text(direction)
    case direction.downcase
    when 'incoming' then Incoming
    when 'outgoing' then Outgoing
    when 'bidirectional' then Bidirectional
    else -1
    end
  end

  def throttle_opt
    self.throttle.nil? ? 'off' : 'on'
  end

  def logger
    @logger = AccountLogger.new self.account_id
  end

  def merge(other)
    [:name, :kind, :protocol, :direction, :enabled, :priority, :configuration, :restrictions, :address, :ao_cost, :at_cost, :ao_rules, :at_rules].each do |sym|
      write_attribute sym, other.read_attribute(sym) if !other.read_attribute(sym).nil?
    end
  end

  # Perform validations that are lengthy, like checking a connection works
  def check_valid_in_ui
  end

  # Return some info about this channel
  def info
    ''
  end

  # Returns additional info for the given ao_msg in a hash, to be
  # displayed in the message view
  def more_info(ao_msg)
    {}
  end

  # Custom logic to be executed when this channel changes
  # because it's account or application changed
  def on_changed
  end

  def bind_queue
  end

  def connected_cache_key
    "channel_connected_#{id}"
  end

  def queued_ao_messages_count
    ao_messages.with_state('queued').count
  end

  def reroute_messages
    other_channels = account.channels.enabled.outgoing.where(:protocol => protocol).all
    return unless other_channels.present?

    queued_messages = ao_messages.with_state('queued').includes(:application).all
    @requeued_messages_count = queued_messages.length
    queued_messages.each { |msg| msg.application.route_ao msg, 'user' if msg.application }
  end

  def requeued_messages_count
    @requeued_messages_count || 0
  end
end
