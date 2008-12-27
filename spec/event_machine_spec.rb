require "#{File.dirname(__FILE__)}/spec_helper"
require 'lib/irc/event_machine'

describe "IRC::EMCore" do

  before(:each) do
    @core = IRC::EMCore.new(nil)
  end
  
  it "should buffer lines until getting EOL" do
    @core.receive_data("").should == 0
    @core.receive_data("\r").should == 0
    @core.receive_data("\r\n").should == 0
    @core.receive_data("\r\nhei").should == 0
    @core.receive_data("b\r\n").should == 1
    @core.receive_data("foo\r\n\r\n\r\n\r\nbar\r\n").should == 2
    
    @core.should_receive(:produce_event).twice.with("foo\r\n")
    @core.receive_data("\r\nfoo\r\nfoo\r\n\r\n")
  end
  
  
  
end