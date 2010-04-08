require 'twitter'

class TwitterChannelHandler < ChannelHandler
  def handle(msg)
    Queues.publish_ao msg, create_job(msg)
  end
  
  def handle_now(msg)
    create_job(msg).perform
  end
  
  def create_job(msg)
    SendTwitterMessageJob.new(@channel.application_id, @channel.id, msg.id)
  end
  
  def update(params)
    @channel.configuration[:welcome_message] = params[:configuration][:welcome_message]
  end
  
  def self.new_oauth
    oauth = Twitter::OAuth.new(TwitterConsumerConfig['token'], TwitterConsumerConfig['secret'])
    oauth.set_callback_url(TwitterConsumerConfig['callback_url'])
    oauth
  end
  
  def self.new_client(config)
    oauth = TwitterChannelHandler.new_oauth
    oauth.authorize_from_access(config[:token], config[:secret])
    
    Twitter::Base.new(oauth)
  end
  
  def info
    @channel.configuration[:screen_name] +
      " <a href=\"#\" onclick=\"twitter_view_rate_limit_status(#{@channel.id}); return false;\">view rate limit status</a>"
  end
  
  def get_rate_limit_status
    client = TwitterChannelHandler.new_client @channel.configuration
    stat = client.rate_limit_status
    "Hourly limit: #{stat.hourly_limit}, Remaining hits for this hour: #{stat.remaining_hits}"
  end
  
  def on_enable
    @channel.create_task 'twitter-receive', TWITTER_RECEIVE_INTERVAL, 
      ReceiveTwitterMessageJob.new(@channel.application_id, @channel.id)
    
    Queues.bind_ao @channel
    Queues.publish_notification ChannelEnabledJob.new(@channel)
  end
  
  def on_disable
    @channel.drop_task('twitter-receive')
  end
  
  def on_destroy
    on_disable
  end
  
end
