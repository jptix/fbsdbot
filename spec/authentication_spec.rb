require "#{File.dirname(__FILE__)}/spec_helper"
require "#{File.dirname(__FILE__)}/../lib/authentication"

describe "corecommands" do
  include SpecHelpers
  
  before(:each) do
    @plugin = Plugin.registered_plugins[:authentication]
    @file = 'test-fbsdbot-userstore.yml'
    User.datastore = YAMLUserStore.new(@file)
  end
  
  after(:all) do
    FileUtils.rm(@file)
  end
  
  describe "!auth identify <pass>" do
    it "should identify the user if given the correct password" do
      event = mock('event')
      user = User.new("foo", "bar", "baz")
      user.password = "foobar"
      user.save
      
      event.stub!(:message).and_return("!auth identify foobar")
      event.stub!(:user).and_return(user)
      event.should_receive(:reply).with("Ok.")
      
      @plugin.on_cmd_auth(event)
    end
    
    it "should not identify the user if given an incorrect password" do
      event = mock('event')
      user = User.new("foo", "bar", "baz")
      user.password = "foobar"
      
      event.stub!(:message).and_return("!auth identify foobarbaz")
      event.stub!(:user).and_return(user)
      event.should_receive(:reply).with("Incorrect password.")
      
      @plugin.on_cmd_auth(event)
    end
  end
  
  
  describe "!auth set <nick> <level>" do
    it "should set the specified user to the specified access level" do
      event, worker = mock_event_with_worker
      user = User.new(*%w[foo bar baz])
      user.set_flag(:bot_master)
      user.save
  
      changing_user = User.new(*%w[a b c])
      changing_user.save
      
      event.stub!(:message).and_return("!auth set a channel_master")
      event.stub!(:user).and_return(user)
      event.should_receive(:reply).with("User is now a channel_master.")
      
      @plugin.on_cmd_auth(event)
      
      changing_user.should be_channel_master
    end
  end
end