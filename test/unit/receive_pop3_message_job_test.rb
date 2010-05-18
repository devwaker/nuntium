require 'test_helper'
require 'net/pop'
require 'yaml'
require 'mocha'

class ReceivePop3MessageJobTest < ActiveSupport::TestCase
  include Mocha::API
  
  def setup
    @chan = Channel.make :pop3
    @email = ATMessage.make_unsaved :email
  end

  should "perform no ssl" do
    mail = mock('Net::POPMail')
    mail.stubs :pop => msg_as_email(@email)
    
    expect_connection @chan, mail
    
    receive
    expect_at_message
  end
  
  should "perform ssl" do
    @chan.configuration[:use_ssl] = '1'
    @chan.save!
      
    mail = mock('Net::POPMail')
    mail.stubs :pop => msg_as_email(@email)
    
    expect_connection @chan, mail
    
    receive
    expect_at_message
  end
  
  should "perform no message id" do
    @email.guid = nil
  
    mail = mock('Net::POPMail')
    mail.stubs :pop => msg_as_email(@email)
      
    expect_connection @chan, mail
    
    receive
    expect_at_message
  end
  
  def msg_as_email(email)
    msg = ""
    msg << "From: #{email.from.without_protocol}\n"
    msg << "To: #{email.to.without_protocol}\n"
    msg << "Subject: #{email.subject}\n"
    msg << "Date: Thu, 5 Nov 2009 14:52:54 +0100\n"
    msg << "Message-ID: <#{email.guid}@baci.local.tmail>\n" unless email.guid.blank?
    msg << "\n"
    msg << email.body
    msg
  end
  
  def expect_connection(chan, mail)
    pop = mock('Net::Pop3')
    Net::POP3.expects(:new).with(chan.configuration[:host], chan.configuration[:port]).returns(pop)
    pop.expects(:enable_ssl).with(OpenSSL::SSL::VERIFY_NONE) if chan.configuration[:use_ssl] == '1'
    pop.expects(:start).with(chan.configuration[:user], chan.configuration[:password])
    pop.expects(:each_mail).yields(mail)
    mail.expects(:delete)
    pop.expects(:finish)
  end
  
  def receive
    job = ReceivePop3MessageJob.new(@chan.account.id, @chan.id)
    job.perform
  end
  
  def expect_at_message
    msgs = ATMessage.all
    assert_equal 1, msgs.length
    
    msg = msgs[0]
    assert_equal @chan.account.id, msg.account_id
    [:from, :to, :subject, :body].each do |field|
      assert_equal @email.send(field).strip, msg.send(field).strip
    end
    assert_equal "<#{@email.guid}@baci.local.tmail>", msg.channel_relative_id if @email.guid.present?
    assert_not_nil msg.guid
    assert_equal Time.parse('Thu, 5 Nov 2009 14:52:54 +0100'), msg.timestamp
  end
end
