require "#{File.dirname(__FILE__)}/../lib/irc/event"
include FBSDBot

describe "Event" do
  it "sets the 'message' and 'channel' attributes when the params hash is set" do
    e = Event.new(:foo)
    data = {:message => 'foo', :to => 'bar'}
    
    e.params = data
    
    e.message.should == data[:message]
    e.channel.should == data[:to]
  end

  it "sets the 'from' and 'hostmask' attributes when the sender hash is set" do
    e = Event.new(:foo)
    data = {:user => 'foo', :nick => 'bar', :host => 'baz'}
    
    e.sender = data
    
    e.from.should == data[:nick]
    e.hostmask.should == "#{data[:user]}@#{data[:host]}"
  end
end