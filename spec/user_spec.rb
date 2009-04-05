# encoding: utf-8
require "#{File.dirname(__FILE__)}/spec_helper"

describe "User" do
  include FBSDBot::Exceptions
  
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
      u = User.new(:nick => "jptix", :user => "markus", :host => "example.com")
      
      u.nick.should == "jptix"
      u.user.should == "markus"
      u.host.should == "example.com"
    end
    
    it "should create a new User object with the given hostmask regexp" do
      rx = /foobar/
      u = User.new(:hostmask_exp => rx)
      u.hostmask_exp.should == rx
      u.nick.should be_nil
      u.user.should be_nil
      u.host.should be_nil
    end
  end
  
  describe "#update" do
    it "should update the user with the given nick, user, host" do
      u = User.new(:hostmask_exp => /foobar/)
      u.update("foobar", "baz", "example.com")
      u.hostmask_exp.should == /foobar/
      u.nick.should == "foobar"
      u.user.should == "baz"
      u.host.should == "example.com"
    end
    
    it "should complain if the given nick,host,mask doesn't match the user's hostmask regexp" do
      u = User.new(:hostmask_exp => /foobar/)
      lambda { u.update("a", "b", "c") }.should raise_error(HostmaskMismatchError)
    end
  end
  
  describe "#hostmask" do
    it "should return the user's hostmask as one string" do
      u = User.new(:nick => "jptix", :user => "markus", :host => "example.com")
      u.hostmask.should == "jptix!markus@example.com"
    end
  end

  describe "#hostmask_exp=" do
    it "should set the user's hostmask regexp" do
      rx = /jptix!markus@example\.com/
      u = User.new(:nick => "jptix", :user => "markus", :host => "example.com")
      u.hostmask_exp = rx
      u.hostmask_exp.should == rx
    end
    
    it "should raise an error if the given hostmask doesn't match the user's values" do
      u = User.new(:nick => "jptix", :user => "markus", :host => "example.com")
      lambda { u.hostmask_exp = /foobar/ }.should raise_error(HostmaskMismatchError)
    end
  end

  describe "#save" do
    it "should save the user to the datastore" do
      u = User.new(:nick => "jptix", :user => "markus", :host => "example.com")
      u.save
      
      User.datastore.fetch(:hostmask => u.hostmask).should == u
    end
  end
  
  describe "#[un]set_flag" do
    it "should set or unset the specified flag" do
      u = User.new(:nick => "jptix", :user => "markus", :host => "example.com")
      u.save

      u.set_flag(:admin)
      u.has_flag?(:admin).should be_true
      
      u.unset_flag(:admin)
      u.has_flag?(:admin).should be_false
    end
  end
  
  describe "=~" do
    it "should compare the user's hostmask with the given user's hostmask regexp" do
      u = User.new(:nick => "jptix", :user => "markus", :host => "example.com")
      
      other = User.new(:hostmask_exp => /jptix!\w+@example\.com/)
      other.should =~ u
      u.should =~ other
    end
  end
  
end
