require "#{File.dirname(__FILE__)}/spec_helper"
require "#{File.dirname(__FILE__)}/../lib/corecommands"

describe "Plugin - corecommands" do
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
end