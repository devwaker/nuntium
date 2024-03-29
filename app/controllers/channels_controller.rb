class ChannelsController < ApplicationController
  include CustomAttributesControllerCommon
  include RulesControllerCommon

  expose(:queued_ao_messages_count_by_channel_id) { account.queued_ao_messages_count_by_channel_id }
  expose(:connected_by_channel_id) { Channel.connected(channels) }

  before_filter :set_channel_parameters, :only => [:create, :update]
  def set_channel_parameters
    channel.account_id = account.id
    channel.throttle = params[:channel][:throttle_opt] == 'on' ? params[:channel][:throttle].to_i : nil
    channel.restrictions = get_custom_attributes
    channel.ao_rules = get_rules :aorules
    channel.at_rules = get_rules :atrules
    channel.check_valid_in_ui
  end

  before_filter :ban_if_logged_in_as_application_and_channel_doesnt_belong_to_an_application
  def ban_if_logged_in_as_application_and_channel_doesnt_belong_to_an_application
    if logged_in_application && channel.persisted? && channel.application_id != logged_in_application.id
      redirect_to channels_path
      false
    else
      true
    end
  end

  def create
    if channel.save
      redirect_to channels_path, :notice => "Channel #{channel.name} was created"
    else
      render :new
    end
  end

  def update
    if channel.save
      redirect_to channels_path, :notice => "Channel #{channel.name} was updated"
    else
      render :edit
    end
  end

  def destroy
    channel.destroy
    redirect_to channels_path, :notice => "Channel #{channel.name} was deleted"
  end

  def enable
    channel.enabled = true
    channel.save!

    render :text => "Channel #{channel.name} was enabled"
  end

  def disable
    channel.enabled = false
    channel.save!

    case channel.requeued_messages_count
    when 0
      render :text => "Channel #{channel.name} was disabled"
    when 1
      render :text => "Channel #{channel.name} was disabled and 1 message was re-queued"
    else
      render :text => "Channel #{channel.name} was disabled and #{channel.requeued_messages_count} messages were re-queued"
    end
  end

  def pause
    channel.paused = true
    channel.save!

    render :text => "Channel #{channel.name} was paused"
  end

  def resume
    channel.paused = false
    channel.save!

    render :text => "Channel #{channel.name} was resumed"
  end
end
