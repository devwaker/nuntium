require 'test_helper'

class ChannelTest < ActiveSupport::TestCase
  test "should not save if name is blank" do
    app = Application.create(:name => 'app', :password => 'foo')
    chan = Channel.new(:application_id => app.id, :kind => 'qst', :protocol => 'sms', :configuration => {:password => 'pass'})
    assert !chan.save
  end
  
  test "should not save if kind is blank" do
    app = Application.create(:name => 'app', :password => 'foo')
    chan = Channel.new(:application_id => app.id, :name => 'chan', :protocol => 'sms', :configuration => {:password => 'pass'})
    assert !chan.save
  end
  
  test "should not save if protocol is blank" do
    app = Application.create(:name => 'app', :password => 'foo')
    chan = Channel.new(:application_id => app.id, :name => 'chan', :kind => 'qst', :configuration => {:password => 'pass'})
    assert !chan.save
  end
  
  test "should not save if name is taken" do
    app = Application.create(:name => 'app', :password => 'foo')
    Channel.new(:application_id => app, :name => 'chan', :kind => 'qst', :configuration => {:password => 'foo', :password_confirmation => 'foo2'})
    chan = Channel.new(:application_id => app.id, :name => 'chan', :kind => 'qst', :protocol => 'sms', :configuration => {:password => 'foo', :password_confirmation => 'foo2'})
    assert !chan.save
  end
  
  test "should not save if application_id is blank" do
    app = Application.create(:name => 'app', :password => 'foo')
    chan = Channel.new(:name => 'chan', :kind => 'qst', :protocol => 'sms', :configuration => {:password => 'foo', :password_confirmation => 'foo'})
    assert !chan.save
  end
end
