# encoding: utf-8
require "#{File.dirname(__FILE__)}/spec_helper"

describe "Event" do

  it "should not show the @worker instance variable on #inspect" do
    event = Event.new(mock('worker'))
    event.inspect.should_not include("worker")
  end

  it "should show other instance variables for #inspect" do
    event = EndOfMotdEvent.new(mock('worker'), :server => 'irc.homelien.no') 
    event.inspect.should =~ /^#<FBSDBot::EndOfMotdEvent\(:end_of_motd\):0x[0-9a-f]+ @discard=false @server=\"irc.homelien.no\" @stop=false>$/
  end

end
