require 'test_helper'

class SendDtacMessageJobTest < ActiveSupport::TestCase
  def setup
    @chan = Channel.make :dtac
  end

  should "perform" do
    response = mock('Net::HTTPResponse')
    response.stubs(
      :code => '200', 
      :message => 'OK', 
      :content_type => 'text/plain', 
      :read_body => 'Status=0')
      
    msg = AOMessage.make :account => Account.make, :channel => @chan
    
    expect_http_post msg, response    
    assert_true (deliver msg)
    
    msg = AOMessage.first
    assert_equal 1, msg.tries
    assert_equal 'delivered', msg.state
  end
  
  def expect_http_post(msg, response)
    encoded = ActiveSupport::Multibyte::Chars.u_unpack(msg.subject_and_body).map { |i| i.to_s(16).rjust(4, '0') }    
    Net::HTTP.expects(:post_form).with do |uri, params|
      params['Msn'] == msg.to.without_protocol &&
      params['Sno'] == msg.from.without_protocol &&
      params['Sender'] == msg.from.without_protocol &&
      params['Msg'] == encoded.to_s &&
      params['Encoding'] == 25 &&
      params['MsgType'] == 'H' &&
      params['User'] == @chan.configuration[:user] &&
      params['Password'] == @chan.configuration[:password]
    end.returns(response)
  end
  
  def deliver(msg)
    job = SendDtacMessageJob.new(@chan.account.id, @chan.id, msg.id)
    job.perform
  end
  
  def check_message_was_delivered(channel_relative_id)
    msg = AOMessage.first
    assert_equal channel_relative_id, msg.channel_relative_id
    assert_equal 1, msg.tries
    assert_equal 'delivered', msg.state
  end
end
