require 'test_helper'
require 'mocha'

class GenericWorkerServiceTest < ActiveSupport::TestCase

  self.use_transactional_fixtures = false

  include Mocha::API
  
  @@id = 10000000
  
  def setup
		clean_database

    @@id = @@id + 1
    @app = Application.create!(:name => 'app', :password => 'foo')
    @service = GenericWorkerService.new(@@id, 0.1)
    
    @chan = Channel.new(:application_id => @app.id, :name => 'chan', :kind => 'clickatell', :protocol => 'sms', :direction => Channel::Outgoing)
    @chan.configuration = {:user => 'user', :password => 'password', :api_id => 'api_id', :from => 'something', :incoming_password => 'incoming_pass' }
    @chan.save!

    Queues.purge_notifications @@id
		clean_queues
    
    StubGenericJob.value_after_perform = nil
  end

	def teardown
	  @service.stop false # do not stop event machine
		clean_database
		clean_queues
	end

  test "should subscribe to enabled channels" do
    Queues.expects(:subscribe_ao).with(@chan, kind_of(MQ))
    
    @service.start
  end
  
  test "should subscribe to notifications" do
    Queues.expects(:subscribe_notifications).with(@@id, kind_of(MQ))
    
    @service.start
  end
  
  test "should execute job when enqueued" do
    @service.start
    
    msg = AOMessage.create!(:application => @app, :channel => @chan)
    
    Queues.publish_ao msg, StubGenericJob.new
    sleep 0.3
    
    assert_equal 10, StubGenericJob.value_after_perform
  end
  
  test "should execute job notification when enqueued" do
    @service.start
    
    Queues.publish_notification StubGenericJob.new
    sleep 0.5
    
    assert_equal 10, StubGenericJob.value_after_perform
    assert_equal @service, StubGenericJob.arguments[0]
  end
  
  test "should stand to disable channel on permanent exception" do
    @service.start
        
    msg = AOMessage.create!(:application => @app, :channel => @chan)
    
    Queues.publish_ao msg, FailingGenericJob.new(PermanentException.new(Exception.new('lorem')))
    sleep 0.3
    
    @chan.reload
    assert_false @chan.enabled  
  end
  test "should unsubscribe when told so" do
    @service.start
    @service.unsubscribe_from_channel @chan.id
    sleep 0.3
    
    msg = AOMessage.create!(:application => @app, :channel => @chan)
    
    Queues.publish_ao msg, StubGenericJob.new
    sleep 0.3
    
    assert_nil StubGenericJob.value_after_perform
  end

  test "should stand to unsubscribe channel temporarily on unknown exception" do
    @service.start
    jobs = []
    
    Queues.expects(:publish_notification).times(2).with do |job,mq|
      jobs << job
      job.channel_id == @chan.id
    end
        
    msg = AOMessage.create!(:application => @app, :channel => @chan)
    
    Queues.publish_ao msg, FailingGenericJob.new(Exception.new('lorem'))  
    sleep 0.6
    
    assert_equal 2, jobs.size
    assert_kind_of ChannelUnsubscriptionJob, jobs[0]
    assert_kind_of ChannelSubscriptionJob, jobs[1]
  end
  
  test "should subscribe when told so" do
    @service.start
    @service.unsubscribe_from_channel @chan.id
    sleep 0.3
    
    @service.subscribe_to_channel @chan.id
    sleep 0.3
    
    msg = AOMessage.create!(:application => @app, :channel => @chan)
    
    Queues.publish_ao msg, StubGenericJob.new
    sleep 0.3
    
    assert_equal 10, StubGenericJob.value_after_perform
  end
  
   test "should not subscribe when told so if channel is disabled" do
    @service.start
    @service.unsubscribe_from_channel @chan.id
    sleep 0.3
    
    @chan.enabled = false
    @chan.save!
    
    @service.subscribe_to_channel @chan.id
    sleep 2
    
    msg = AOMessage.create!(:application => @app, :channel => @chan)
    
    Queues.publish_ao msg, StubGenericJob.new
    sleep 2
    
    assert_nil StubGenericJob.value_after_perform
  end
  
  def clean_database
    [Application, ApplicationLog, Channel, AOMessage].each(&:delete_all)
  end

	def clean_queues
		Channel.all.each {|c| Queues.purge_ao c}
		sleep 0.3
	end
  
end

class StubGenericJob

  class << self
    attr_accessor :value_after_perform
    attr_accessor :arguments
  end
  
  def perform(*args)
    puts "EXECUTING #{self}"
    StubGenericJob.value_after_perform = 10
    StubGenericJob.arguments = args
  end

end

class FailingGenericJob
  def initialize(ex)
    @ex = ex
  end
  
  def perform
    raise @ex
  end
end
