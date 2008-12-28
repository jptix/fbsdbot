require "#{File.dirname(__FILE__)}/spec_helper"

describe "User" do

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
  
  describe "#string" do
    it "should return the user's attributes as one string" do
      nick, user, host = "jptix", "markus", "example.com"
      u = User.new(nick, user, host)
      u.string.should == "jptix!markus@example.com"
    end
  end

  describe "#password=" do
    it "should set the password to the SHA1 of the given string" do
      nick, user, host = "jptix", "markus", "example.com"
      u = User.new(nick, user, host)
      u.password = 'foo'
      u.password.should == Digest::SHA1.hexdigest('foo')
    end
  end
  
  describe "#save" do
    it "should save the user to the datastore" do
      
    end
  end
  
  describe "#identify" do
    it "should identify the user with the given password" do
      nick, user, host = "jptix", "markus", "example.com"
      user = User.new(nick, user, host)
      user.password = "foo"
      User.datastore.save(user)
      
      identified_user = user.identify("foo")
      
      identified_user.should be_instance_of(User)
      identified_user.should be_identified
      identified_user.nick.should == user.nick
      identified_user.user.should == user.user
      identified_user.host.should == user.host
    end
    
    it "should not identify the user if the password is wrong" do
      nick, user, host = "jptix", "markus", "example.com"
      user = User.new(nick, user, host)
      user.password = "foo"
      User.datastore.save(user)

      user.identify('bar').should be_nil
    end
  end
  
end