require "#{File.dirname(__FILE__)}/spec_helper"

describe "User" do

  describe "#new" do
    it "should create a new User object with the given nick, user and host" do
      nick, user, host = "jptix", "markus", "example.com"
      
      u = User.new(nick, user, host)
      u.nick.should == nick
      u.user.should == user
      u.host.should == host
    end
  end
  

  
end