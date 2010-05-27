# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

require 'stringio'
require 'zlib'

class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time
  # protect_from_forgery # See ActionController::RequestForgeryProtection for details

  # Scrub sensitive parameters from your log
  filter_parameter_logging :password

  # Given an array of AOMessage or ATMessage, this methods
  # returns two arrays:
  #  - The first one has the messages which have tries < account.max_tries
  #  - The second one has the messages which have tries >= account.max_tries
  def filter_tries_exceeded_and_not_exceeded(msgs, account)
    valid_messages = []
    invalid_messages = []
    
    msgs.each do |msg|
      if msg.tries >= account.max_tries
        invalid_messages.push msg
      else
        valid_messages.push msg
      end
    end
    
    [valid_messages, invalid_messages]
  end
  
  def compress
    accept = self.request.env['HTTP_ACCEPT_ENCODING']
    if accept && accept.match(/gzip/)
      encoding = self.response.headers["Content-Transfer-Encoding"]
      if encoding != 'binary'
        begin 
          ostream = StringIO.new
          gz = Zlib::GzipWriter.new(ostream)
          gz.write(self.response.body)
          self.response.body = ostream.string
          self.response.headers['Content-Encoding'] = 'gzip'
        ensure
          gz.close
        end
      end
    end
  end

end
