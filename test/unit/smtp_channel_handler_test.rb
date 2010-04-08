require 'test_helper'

class SmtpChannelHandlerTest < ActiveSupport::TestCase
  def setup
    @app = Application.create(:name => 'app', :password => 'foo')
    @chan = Channel.new(:application_id => @app.id, :name => 'chan', :kind => 'smtp', :protocol => 'sms')
    @chan.configuration = {:host => 'host', :port => '430', :user => 'user', :password => 'password' }
  end
  
  [:host, :user, :password, :port].each do |field|
    test "should validate configuration presence of #{field}" do
      assert_validates_configuration_presence_of @chan, field
    end
  end
  
  test "should not save if port is not a number" do
    @chan.configuration[:port] = 'foo'
    assert !@chan.save
  end
  
  test "should not save if port is negative" do
    @chan.configuration[:port] = -430
    assert !@chan.save
  end
  
  test "should save" do
    assert @chan.save
  end
  
  test "should enqueue" do
    assert_handler_should_enqueue_ao_job @chan, SendSmtpMessageJob
  end
end
