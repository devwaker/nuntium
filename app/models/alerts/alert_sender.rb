class AlertSender

  def perform
    Alert.all(:conditions => 'sent_at is null', :include => [:channel, :ao_message]).each do |alert|
      begin
        next if alert.channel.nil?
      
        ao_msg = AOMessage.find_by_id alert.ao_message_id
        next if ao_msg.nil?
        
        if ao_msg.tries >= 3
          ao_msg.state = 'failed'
          ao_msg.save!
          alert.failed = true
          alert.sent_at = Time.now.utc
          alert.save!
          return
        end
        
        alert.channel.handle_now(ao_msg)
        alert.sent_at = Time.now.utc
        alert.save!
      rescue Exception => e
        RAILS_DEFAULT_LOGGER.error "#{e.class} #{e.message}"
      end
    end
  end

end
