require "#{File.dirname(__FILE__)}/spec_helper"

describe "Logger" do

  before(:each) do
    @log = Logger.new
  end
  
  def hit_logger
    @log.debug "debug0"
    @log.info  "info1"
    @log.warn  "warn2"
    @log.error "error3"
    @log.fatal "fatal4"
  end
  
  it "should print to $stdout if level is below :warn" do
    out = capture(:stdout) { hit_logger }
    out.split("\n").size.should == 2
  end

  it "should print to $stderr if level is above :warn" do
    out = capture(:stderr) { hit_logger }
    out.split("\n").size.should == 3
  end
  
  it "should not log anything if level is set to :off" do
    @log.level = :off
    out = capture(:stderr) { hit_logger }.should == ""
  end

  
end