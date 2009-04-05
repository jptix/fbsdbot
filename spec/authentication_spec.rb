# encoding: utf-8
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

  describe "!auth set <user-id> <level>" do
    it "should set the specified user to the specified access level" do
      user = User.new(:nick => 'foo', :user => 'bar', :host => 'baz' )
      user.set_flag(:admin)
      user.save

      changing_user = User.new(:nick => 'a', :user => 'b', :host => 'c' )
      changing_user.save

      event = mock('event')
      event.stub!(:message).and_return("!auth set #{changing_user.object_id} admin")
      event.stub!(:user).and_return(user)
      event.stub!(:channel?).and_return(false)
      event.should_receive(:reply).with("User #{changing_user.object_id} is now admin")

      @plugin.on_cmd_auth(event)
      changing_user.should be_admin

      event.stub!(:message).and_return("!auth set #{changing_user.object_id} user")
      event.should_receive(:reply).with("User #{changing_user.object_id} is now user")

      @plugin.on_cmd_auth(event)
      changing_user.should_not be_admin
    end

    it "should not change the access level if the user is a master" do
      user = User.new(:nick => 'foo', :user => 'bar', :host => 'baz' )
      user.set_flag(:admin)
      user.save

      master = User.new(:nick => 'a', :user => 'b', :host => 'c' )
      master.set_flag(:master)
      master.set_flag(:admin)
      master.save

      event = mock('event')
      event.stub!(:message).and_return("!auth set #{master.object_id} user")
      event.stub!(:user).and_return(user)
      event.stub!(:channel?).and_return(false)
      event.should_receive(:reply).with("Cannot change level for master.")

      @plugin.on_cmd_auth(event)
      master.should be_admin
      master.should be_master
    end
  end

  describe "!auth remove <user-id>" do
    it "should remove the user from the datastore" do
      user = User.new(:nick => 'foo', :user => 'bar', :host => 'baz' )
      user.set_flag(:admin)
      user.save

      changing_user = User.new(:nick => 'a', :user => 'b', :host => 'c' )
      changing_user.save

      User.datastore.fetch_all.size.should == 2
      User.datastore.fetch(:user => changing_user).should_not be_nil

      event = mock('event')
      event.stub!(:message).and_return("!auth remove #{changing_user.object_id}")
      event.stub!(:user).and_return(user)
      event.stub!(:channel?).and_return(false)
      event.should_receive(:reply).with("User #{changing_user.object_id} removed")

      @plugin.on_cmd_auth(event)

      User.datastore.fetch_all.size.should == 1
      User.datastore.fetch(:user => changing_user).should be_nil
      User.datastore.fetch_all.should_not include(changing_user)
    end

    it "should not remove the user if it doesn't exist" do
      user = User.new(:nick => 'foo', :user => 'bar', :host => 'baz' )
      user.set_flag(:admin)
      user.save

      event = mock('event')
      event.stub!(:message).and_return("!auth remove 1")
      event.stub!(:user).and_return(user)
      event.stub!(:channel?).and_return(false)
      event.should_receive(:reply).with("User not found. Use `!auth list` to show all users.")

      @plugin.on_cmd_auth(event)
    end

    it "should not remove the user if the master flag is set" do
      user = User.new(:nick => 'foo', :user => 'bar', :host => 'baz' )
      user.set_flag(:admin)
      user.save

      master = User.new(:hostmask_exp => /foobar/)
      master.set_flag(:master)
      master.save

      event = mock('event')
      event.stub!(:message).and_return("!auth remove #{master.object_id}")
      event.stub!(:user).and_return(user)
      event.stub!(:channel?).and_return(false)
      event.should_receive(:reply).with("Cannot remove master.")

      @plugin.on_cmd_auth(event)
    end
  end

  describe "!auth add <regexp>" do
    it "should add a user with the given regexp" do
      user = User.new(:nick => 'foo', :user => 'bar', :host => 'baz' )
      user.set_flag(:admin)
      user.save
      
      event = mock('event')
      event.stub!(:message).and_return("!auth add /foobar/")
      event.stub!(:user).and_return(user)
      event.stub!(:channel?).and_return(false)
      event.should_receive(:reply) { |string| string.should =~ %r{Added user \d+ for /foobar/} }
      
      @plugin.on_cmd_auth(event)
    end

    # TODO: this behaviour should probably be changed / improved 
    it "should not add the user if the regexp is in use by an existing user" do
      user = User.new(:hostmask_exp => /foobar/ )
      user.set_flag(:admin)
      user.save
      
      event = mock('event')
      event.stub!(:message).and_return("!auth add /foobar/")
      event.stub!(:user).and_return(user)
      event.stub!(:channel?).and_return(false)
      event.should_receive(:reply).with("User already added for /foobar/")
      
      @plugin.on_cmd_auth(event)
    end

  end
end
