# encoding: utf-8
require "#{File.dirname(__FILE__)}/spec_helper"

describe "Plugin" do
  include SpecHelpers

  before(:each) do
    @default_plugins = Plugin.registered_plugins
  end
  
  after(:each) do
    Plugin.instance_variable_set("@registered_plugins", @default_plugins)
  end

  describe "#define" do
    it "should add the defined plugin to it's list of plugins" do
      Plugin.define('foobar') { }

      plugin = Plugin.registered_plugins[:foobar]

      plugin.should be_instance_of(Plugin)
      plugin.name.should == 'foobar' 
    end
    
    it "should look at the plugins methods and add the appropriate event handlers" do
      Plugin.define('foobar') {
        def on_cmd_foo; end
      }
      
      Plugin.instance_variable_get("@event_handlers").keys.should include(:cmd_foo)
    end
  end
  
  describe "#def_field" do
    it "should define class methods to get and set the given fields" do
      Plugin.def_field :bar
      plugin = Plugin.define("foo") {}

      plugin.bar.should be_nil
      plugin.bar(:bar)
      plugin.bar.should == :bar
    end
  end

  describe "#reset" do
    it "should remove all registered plugins / event handlers" do
      plugin = Plugin.define("foo") { def on_cmd_foo(event); end }
      
      Plugin.registered_plugins.should_not be_empty
      Plugin.reset!
      Plugin.registered_plugins.should be_empty
    end
  end
  
  describe "#list_plugins" do
    it "should list the currently registered plugins" do
      Plugin.define("foo") {
        author "bar"
        version "1234"
      }

      output = capture(:stdout) do 
        Plugin.list_plugins
      end
      
      output.should =~ /Plugin: foo, 1234> :: Written by bar/
    end
  end
  
  describe "#run_event" do
    it "should send the event to plugins that implements the matching method" do
      a = Plugin.define("a") { def on_cmd_foo(event); end}
      
      conn = mock("conn", :null_object => true)
      opts = {
        :params => ["#bot-test.no", "!foo"],
        :nick   => 'foo',
        :user   => 'bar', 
        :host   => 'baz'
      }
      e = PrivateMessageEvent.new(conn, opts)
      
      a.should_receive(:on_cmd_foo).with(e)
      Plugin.run_event(e)
    end
  end

  
end
