require "#{File.dirname(__FILE__)}/spec_helper"

describe "User" do

  before(:each) do
    @file = 'test-fbsdbot-userstore.yml'
    User.datastore = YAMLUserStore.new(@file)
  end
  
  after(:each) do
    FileUtils.rm(@file)
  end

  describe ".datastore" do
    it "should return the default datastore" do
      User.datastore.class.should == YAMLUserStore
    end
  end

  describe "#new" do
    it "should create a new User object with the given nick, user and host" do
      nick, user, host = "jptix", "markus", "example.com"
      u = User.new(nick, user, host)
      
      u.nick.should == nick
      u.user.should == user
      u.host.should == host
    end
  end
  
  describe "#hostmask" do
    it "should return the user's hostmask as one string" do
      nick, user, host = "jptix", "markus", "example.com"
      u = User.new(nick, user, host)
      u.hostmask.should == "jptix!markus@example.com"
    end
  end

  describe "#save" do
    it "should save the user to the datastore" do
      nick, user, host = "jptix", "markus", "example.com"
      u = User.new(nick, user, host)
      u.save
      
      User.datastore.fetch(:hostmask => u.hostmask).should == u
    end
  end
  
  describe "#[un]set_flag" do
    it "should set or unset the specified flag" do
      nick, user, host = "jptix", "markus", "example.com"
      u = User.new(nick, user, host)
      u.save

      # just admin
      u.set_flag(:admin)
      u.has_flag?(:admin).should be_true
      
      u.unset_flag(:admin)
      u.has_flag?(:admin).should be_false
    end
  end
  
  describe "=~" do
    it "should compare the user's hostmask with the given user's hostmask regexp" do
      nick, user, host = "jptix", "markus", "example.com"
      u = User.new(nick, user, host)
      
      other = User.new(nick, user, host)
      other.hostmask_exp = /jptix!/
    end
  end
  
end