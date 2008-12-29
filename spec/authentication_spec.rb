require "#{File.dirname(__FILE__)}/spec_helper"
require "#{File.dirname(__FILE__)}/../lib/authentication"

describe "authentication" do
  include SpecHelpers
  
  before(:each) do
    @plugin = Plugin.registered_plugins[:authentication]
    @file = 'test-fbsdbot-userstore.yml'
    User.datastore = YAMLUserStore.new(@file)
  end
  
  after(:all) do
    FileUtils.rm(@file)
  end
  
  describe "!auth set <nick> <level>" do
    it "should set the specified user to the specified access level" do
      user = User.new(*%w[foo bar baz])
      user.set_flag(:admin)
      user.save
  
      changing_user = User.new(*%w[a b c])
      changing_user.save
      
      event = mock('event')
      event.stub!(:message).and_return("!auth set a admin")
      event.stub!(:user).and_return(user)
      event.should_receive(:reply).with("User is now admin")
      
      @plugin.on_cmd_auth(event)
      changing_user.should be_admin

      event.stub!(:message).and_return("!auth set a user")
      event.should_receive(:reply).with("User is now user")
      
      @plugin.on_cmd_auth(event)
      changing_user.should_not be_admin
    end
    
  end
end