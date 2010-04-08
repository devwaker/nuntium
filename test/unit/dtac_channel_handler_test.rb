require 'test_helper'

class DtacChannelHandlerTest < ActiveSupport::TestCase
  include Mocha::API
  
  def setup
    @app = Application.create(:name => 'app', :password => 'foo')
    @chan = Channel.new(:application_id => @app.id, :name => 'chan', :kind => 'dtac', :protocol => 'sms')
    @chan.configuration = {:user => 'user', :password => 'password', :sno => 'sno' }
  end
  
  [:user, :password, :sno].each do |field|
    test "should validate configuration presence of #{field}" do
      assert_validates_configuration_presence_of @chan, field
    end
  end
  
  test "should save" do
    assert @chan.save
  end
  
  test "should enqueue" do
    assert_handler_should_enqueue_ao_job @chan, SendDtacMessageJob
  end
  
  test "on enable binds queue" do
    Queues.expects(:bind_ao).with(@chan)
    @chan.save!
  end
  
  test "on enable publish notification" do
    Queues.expects(:publish_notification).with do |job|
      job.kind_of?(ChannelEnabledJob) and job.channel_id == @chan.id
    end
      
    @chan.save!
  end
  
  test "on disable publish notification" do
    test_on_enable_publish_notification
    Queues.expects(:publish_notification).with do |job|
      job.kind_of?(ChannelDisabledJob) and job.channel_id == @chan.id
    end
    
    @chan.enabled = false
    @chan.save!
  end
end
