class ChannelController < AccountAuthenticatedController
  include CustomAttributesControllerCommon
  include RulesControllerCommon

  before_filter :check_login
  before_filter :check_channel, :except => [:new_channel, :create_channel]
  before_filter :set_selected_tab

  def new_channel
    @channel = Channel.new :configuration => {} unless @channel
    kind = params[:kind]
    @channel.kind = kind
    render "new_#{kind}_channel"
  end

  def create_channel
    chan = params[:channel]
    return redirect_to :controller => :home, :action => :channels if chan.nil?

    throttle_opt = chan.delete :throttle_opt

    @channel = Channel.new(chan)
    @channel.account_id = @account.id
    @channel.kind = params[:kind]
    @channel.throttle = throttle_opt == 'on' ? chan[:throttle].to_i : nil
    @channel.restrictions = get_custom_attributes
    @channel.ao_rules = get_rules :aorules
    @channel.at_rules = get_rules :atrules

    @channel.check_valid_in_ui
    if !@channel.save
      @channel.clear_password
      return render "new_#{@channel.kind}_channel"
    end

    flash[:notice] = "Channel #{@channel.name} was created"
    redirect_to :controller => :home, :action => :channels
  end

  def edit_channel
    if view_paths.any?{|p| File.exists? "#{p.to_path}/channel/edit_#{@channel.kind}_channel.html.erb"}
      render "edit_#{@channel.kind}_channel"
    else
      render "new_#{@channel.kind}_channel"
    end
  end

  def update_channel
    chan = params[:channel]
    return redirect_to_home if chan.nil?

    throttle_opt = chan.delete :throttle_opt

    @channel.handler.update(chan)
    @channel.throttle = throttle_opt == 'on' ? chan[:throttle].to_i : nil
    @channel.restrictions = get_custom_attributes
    @channel.ao_rules = get_rules :aorules
    @channel.at_rules = get_rules :atrules

    @channel.check_valid_in_ui
    if !@channel.save
      @channel.clear_password
      return edit_channel
    end

    flash[:notice] = "Channel #{@channel.name} was updated"
    redirect_to :controller => :home, :action => :channels
  end

  def delete_channel
    @channel.destroy

    flash[:notice] = "Channel #{@channel.name} was deleted"
    redirect_to :controller => :home, :action => :channels
  end

  def enable_channel
    @channel.enabled = true
    @channel.save!

    render :text => "Channel #{@channel.name} was enabled"
  end

  def disable_channel
    @channel.enabled = false
    @channel.save!

    # If other channels for the same protocol exist, re-queue
    # queued messages in those channels.
    requeued_messages_count = 0;

    other_channels = @account.channels.select{|c| c.enabled && c.protocol == @channel.protocol && @channel.is_outgoing?}

    if !other_channels.empty?
      queued_messages = @channel.ao_messages.with_state('queued').includes(:application).all
      requeued_messages_count = queued_messages.length
      queued_messages.each do |msg|
        msg.application.route_ao msg, 'user' if msg.application
      end
    end

    if requeued_messages_count == 0
      return render :text => "Channel #{@channel.name} was disabled"
    elsif requeued_messages_count == 1
      return render :text => "Channel #{@channel.name} was disabled and 1 message was re-queued"
    else
      return render :text => "Channel #{@channel.name} was disabled and #{requeued_messages_count} messages were re-queued"
    end
  end

  def pause_channel
    @channel.paused = true
    @channel.save!

    render :text => "Channel #{@channel.name} was paused"
  end

  def resume_channel
    @channel.paused = false
    @channel.save!

    render :text => "Channel #{@channel.name} was resumed"
  end

  protected

  def check_channel
    @channel = @account.find_channel params[:id]
    redirect_to_home if @channel.nil?
  end

  def set_selected_tab
    @selected_tab = :channels
  end
end
