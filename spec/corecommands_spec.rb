# encoding: utf-8
require "#{File.dirname(__FILE__)}/spec_helper"
require "#{File.dirname(__FILE__)}/../lib/corecommands"

describe "corecommands" do
  include SpecHelpers
  
  before(:all) do
    @plugin = Plugin.registered_plugins[:corecommands]
  end
  
  def mock_event_with_worker
    worker = mock('worker')
    event = mock('event')
    event.stub!(:worker).and_return(worker)
    return event, worker
  end
  
  describe "!uptime" do
    it "should reply how long the bot has been running" do
      event, worker = mock_event_with_worker
      worker.stub!(:start_time).and_return(Time.now - 120)
      event.should_receive(:reply).with("I've been running for 2m")
      
      @plugin.on_cmd_uptime(event)
    end
  end
  
  describe "!commands" do
    it "should reply with a list of all the registered bot commands" do
      event = mock('event')
      
      args = []
      event.should_receive(:reply) do |arg|
        args << arg
      end.at_least(:once)
      
      @plugin.on_cmd_commands(event)
      args.any? { |arg| arg.include?(@plugin.commands.join(', ')) }.should be_true
    end
  end

  describe "CTCP Version" do
    it "should reply with a string that includes bot version and ruby version" do
      event = mock('event')
      event.should_receive(:reply) do |arg|
        arg.should include(FBSDBot::VERSION)
        arg.should include(RUBY_VERSION)
      end
      
      @plugin.on_ctcp_version(event)
    end
  end
end
