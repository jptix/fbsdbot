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
    stdout, stderr = capture(:both) { hit_logger }
    stdout.split("\n").size.should == 2
  end

  it "should print to $stderr if level is above :warn" do
    stdout, stderr = capture(:both) { hit_logger }
    stderr.split("\n").size.should == 3
  end

  
end