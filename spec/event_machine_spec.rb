# encoding: utf-8
require "#{File.dirname(__FILE__)}/spec_helper"
require 'lib/irc/em_worker'

include IRC::Constants

describe "IRC::EMWorker" do

  before(:each) do
    @core = IRC::EMWorker.new(nil)
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
      m = mock('event_producer')
      m.should_receive(:parse_line).with("bar\r\n")
      
      @core.instance_variable_set("@event_producer", m)
      @core.receive_data("")
      @core.receive_data(EOL)
      @core.receive_data("\r\nbar\r\n")
    end
  end
  
end
