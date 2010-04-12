require 'uri'
require 'net/http'
require 'net/https'

class ClickatellChannelHandler < GenericChannelHandler

  def job_class
    SendClickatellMessageJob
  end
  
  def check_valid
    check_config_not_blank :api_id
    
    if (@channel.direction & Channel::Incoming) != 0    
      check_config_not_blank :incoming_password
    end
    
    if (@channel.direction & Channel::Outgoing) != 0
      check_config_not_blank :user, :password, :from
    end
  end
  
  def info
    @channel.configuration[:user] + " / " << @channel.configuration[:api_id] <<
      " <a href=\"#\" onclick=\"clickatell_view_credit(#{@channel.id}); return false;\">view credit</a>"
  end
  
  def more_info(ao_msg)
    return {} if ao_msg.channel_relative_id.nil?
    
    begin
      status = get_status(ao_msg)
      idx = status.index 'Status:'
      if idx == -1
        {'Clickatell status' => status}
      else
        status = status[idx + 7 .. -1].strip
        codes = @@clickatell_statuses[status]
        if codes.nil?
          {'Clickatell status' => status}
        else
          {
            'Clickatell status description' => codes[0],
            'Clickatell status detail' => codes[1]
          }
        end
      end
    rescue Exception => ex
      {'Clickatell status' => 'error retreiving status: #{ex}'}
    end
  end
  
  def get_credit
    cfg = @channel.configuration
    uri = "/http/getbalance?api_id=#{cfg[:api_id]}&user=#{cfg[:user]}&password=#{cfg[:password]}"
    host = URI::parse('http://api.clickatell.com')
    Net::HTTP::new(host.host, host.port).get(uri).body
  end
  
  def get_status(ao_msg)
    cfg = @channel.configuration
    uri = "/http/querymsg?api_id=#{cfg[:api_id]}&user=#{cfg[:user]}&password=#{cfg[:password]}&apimsgid=#{ao_msg.channel_relative_id}"
    host = URI::parse('https://api.clickatell.com')
    request = Net::HTTP::new(host.host, host.port)
    request.use_ssl = true
    request.verify_mode = OpenSSL::SSL::VERIFY_NONE
    request.get(uri).body
  end
  
  @@clickatell_statuses = {
    '001' => ['Message unknown', 'The message ID is incorrect or reporting is delayed.'],
    '002' => ['Message queued', 'The message could not be delivered and has been queued for attempted redelivery.'],
    '003' => ['Delivered to gateway', 'Delivered to the upstream gateway or network (delivered to the recipient).'],
    '004' => ['Received by recipient', 'Confirmation of receipt on the handset of the recipient.'],
    '005' => ['Error with message', 'There was an error with the message, probably caused by the content of the message itself.'],
    '006' => ['User cancelled message delivery', 'The message was terminated by a user (stop message command) or by our staff.'],
    '007' => ['Error delivering message', 'An error occurred delivering the message to the handset.'],
    '008' => ['OK', 'Message received by gateway.'],
    '009' => ['Routing error', 'The routing gateway or network has had an error routing the message.'],
    '010' => ['Message expired', 'Message has expired before we were able to deliver it to the upstream gateway. No charge applies.'],
    '00A' => ['Message expired', 'Message has expired before we were able to deliver it to the upstream gateway. No charge applies.'],
    '011' => ['Message queued for later delivery', 'Message has been queued at the gateway for delivery at a later time (delayed delivery).'],
    '00B' => ['Message queued for later delivery', 'Message has been queued at the gateway for delivery at a later time (delayed delivery).'],
    '012' => ['Out of credit', 'The message cannot be delivered due to a lack of funds in your account. Please re-purchase credits.'],
    '00C' => ['Out of credit', 'The message cannot be delivered due to a lack of funds in your account. Please re-purchase credits.']
    }
  
=begin
  Clickatell errors are mapped as fatal, temporary, message or unexpected.
  These categories are used to trap exceptions for SendMessageJob.
=end  
  CLICKATELL_ERRORS = {
    1 => { :kind => :fatal, :description => 'Authentication failed'},
    2 => { :kind => :fatal, :description => 'Unknown username or password'},
    3 => { :kind => :unexpected, :description => 'Session ID expired'},
    4 => { :kind => :fatal, :description => 'Account frozen'},
    5 => { :kind => :unexpected, :description => 'Missing session ID'},
    7 => { :kind => :fatal, :description => 'IP Lockdown violation'},
    101 => { :kind => :message, :description => 'Invalid or missing parameters'},
    102 => { :kind => :message, :description => 'Invalid user data header'},
    103 => { :kind => :message, :description => 'Unknown API message ID'},
    104 => { :kind => :message, :description => 'Unknown client message ID'},
    105 => { :kind => :message, :description => 'Invalid destination address'},
    106 => { :kind => :message, :description => 'Invalid source address'},
    107 => { :kind => :message, :description => 'Empty message'},
    108 => { :kind => :fatal, :description => 'Invalid or missing API ID'},
    109 => { :kind => :fatal, :description => 'Missing message ID'},
    110 => { :kind => :unexpected, :description => 'Error with email message'},
    111 => { :kind => :unexpected, :description => 'Invalid protocol'},
    112 => { :kind => :message, :description => 'Invalid message type'},
    113 => { :kind => :message, :description => 'Maximum message parts exceeded'},
    114 => { :kind => :message, :description => 'Cannot route message'},
    115 => { :kind => :message, :description => 'Message expired'},
    116 => { :kind => :message, :description => 'Invalid Unicode data'},
    120 => { :kind => :message, :description => 'Invalid delivery time'},
    121 => { :kind => :message, :description => 'Destination mobile number'},
    122 => { :kind => :message, :description => 'Destination mobile opted out'},
    123 => { :kind => :fatal, :description => 'Invalid Sender ID'},
    128 => { :kind => :message, :description => 'Number delisted'},
    201 => { :kind => :unexpected, :description => 'Invalid batch ID'},
    202 => { :kind => :unexpected, :description => 'No batch template'},
    301 => { :kind => :fatal, :description => 'No credit left'},
    302 => { :kind => :message, :description => 'Max allowed credit'}
  }
end
