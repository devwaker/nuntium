class SmppChannel < Channel
  include ServiceChannel

  has_many :smpp_message_parts, :foreign_key => 'channel_id'

  configuration_accessor :user, :password
  configuration_accessor :host, :port, :source_ton, :source_npi, :destination_ton, :destination_npi
  configuration_accessor :system_type, :default => 'vma'
  configuration_accessor :default_mo_encoding, :mt_encodings, :mt_csms_method
  configuration_accessor :accept_mo_hex_string, :mt_max_length
  configuration_accessor :endianness_mo, :endianness_mt
  configuration_accessor :max_unacknowledged_messages, :default => 5
  configuration_accessor :suspension_codes, :rejection_codes

  validates_presence_of :host, :system_type
  validates_presence_of :user, :password, :default_mo_encoding, :mt_encodings, :mt_csms_method
  validates_numericality_of :port, :greater_than => 0
  validates_numericality_of :source_ton, :source_npi, :destination_ton, :destination_npi, :greater_than_or_equal_to => 0, :less_than_or_equal_to => 7

  def self.title
    "SMPP"
  end

  def self.default_protocol
    'sms'
  end

  def check_valid_in_ui
    # what kind of validation should we put here?
    # what if the smpp connection require a vpn?
  end

  def info
    str = "#{user}@#{host}:#{port}"
    str << " (#{throttle}/min)" if throttle != 0
    str
  end

  def suspension_codes_as_array
    return [] unless suspension_codes
    suspension_codes.split(",").reject{|x| !x.integer?}.map(&:to_i)
  end

  def rejection_codes_as_array
    return [] unless rejection_codes
    rejection_codes.split(",").reject{|x| !x.integer?}.map(&:to_i)
  end
end
