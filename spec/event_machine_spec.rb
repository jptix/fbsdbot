require "#{File.dirname(__FILE__)}/spec_helper"
require 'lib/irc/event_machine'

include IRC::Constants

describe "IRC::EMCore" do

  before(:each) do
    @core = IRC::EMCore.new(nil)
  end
  
  describe "'receive_data'" do
    
    it "should not buffer empty lines" do
      @core.receive_data("").should == 0    
    end
    
    it "should not buffer lines with only EOL" do
      @core.receive_data(EOL).should == 0
      @core.receive_data("\r\n").should == 0
    end
    
    it "should send lines to event_producer with terminating EOL" do
      @core.receive_data("")
      @core.receive_data(EOL)
      @core.receive_data("bar\r\n")
      
      m = mock('event_producer')
      @core.instance_variable_set("@event_producer", m)
      m.should_receive(:parse_line).with("bar\r\n")

    end
  end
  
end