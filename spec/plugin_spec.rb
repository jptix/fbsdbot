require "#{File.dirname(__FILE__)}/spec_helper"

describe "Plugin" do
  after(:each) do
    Plugin.reset!
  end

  describe "#define" do
    it "should add the defined plugin to it's list of plugins" do
      Plugin.define('foobar') { }

      plugin = Plugin.registered_plugins[:foobar]

      plugin.should be_instance_of(Plugin)
      plugin.name.should == 'foobar' 
    end
  end
  
  describe "#def_field" do
    it "should description" do
      
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

  
end