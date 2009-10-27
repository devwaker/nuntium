# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time
  # protect_from_forgery # See ActionController::RequestForgeryProtection for details

  # Scrub sensitive parameters from your log
  filter_parameter_logging :password

  # Given an array of AOMessage or ATMessage, this methods
  # returns two arrays:
  #  - The first one has the messages which have tries < app.max_tries
  #  - The second one has the *ids* of those who have tries >= app.max_tries
  def filter_tries_exceeded_and_not_exceeded(msgs, app)
    valid_messages = []
    invalid_message_ids = []
    
    msgs.each do |msg|
      if msg.tries >= app.max_tries
        invalid_message_ids.push msg.id
      else
        valid_messages.push msg
      end
    end
    
    [valid_messages, invalid_message_ids]
  end
  
  # Returns protocol of string, nil if none found.
  # Examples:
  # 1. 'sms://foobar' -> 'sms'
  # 2. 'foobar' -> nil
  def get_protocol(address)
    index = address.index '://'
    if index.nil?
      nil
    else
      address[0 ... index]
    end
  end
end
