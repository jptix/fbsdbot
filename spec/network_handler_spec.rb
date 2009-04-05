# encoding: utf-8
require "#{File.dirname(__FILE__)}/spec_helper"

describe "NetworkHandler" do

  describe "#new" do
    it "should create a new NetworkHandler with the given config" do
      config = {
        :nick             => 'test',
        :realname         => 'foo',
        :username         => 'bar',
        :retry_in_seconds => 10,
        :networks         => {}
      }
      
      handler = IRC::NetworkHandler.new(config)
      handler.nick.should == 'test'
      handler.realname.should == 'foo'
      handler.username.should == 'bar'
      handler.retry_in_seconds.should == 10
    end
    
    it "should create a new NetworkHandler with sensible defaults" do
      handler = IRC::NetworkHandler.new(:nick => 'foo', :networks => {})
      handler.realname.should_not be_nil
      handler.username.should_not be_nil
      handler.retry_in_seconds.should be_kind_of(Numeric)
    end
    
    it "should raise ConfigurationError if no :nick is given" do
      lambda { IRC::NetworkHandler.new({}) }.should raise_error(ConfigurationError)
    end

    it "should raise ConfigurationError if no :networks are given" do
      lambda { IRC::NetworkHandler.new(:nick => 'foo') }.should raise_error(ConfigurationError)
    end
  end
  
  describe "#create_worker" do
    it "should create a new worker for the given config" do
      handler = IRC::NetworkHandler.new(:nick => 'foo', :networks => {})
      config = {:servers => %w[irc.homelien.no], :channels => %w[bar]}
      
      IRC::EMWorker.should_receive(:connect).with(handler, :EFNet, config)
      handler.create_worker(:EFNet, config)
    end
    
    it "should raise a TypeError if the given network is not a symbol" do
      handler = IRC::NetworkHandler.new(:nick => 'foo', :networks => {})
      lambda { handler.create_worker("EFNet", {}) }.should raise_error(TypeError)
    end

    it "should raise a TypeError if the given network data is not a Hash" do
      handler = IRC::NetworkHandler.new(:nick => 'foo', :networks => {})
      lambda { handler.create_worker(:EFNet, 'foo') }.should raise_error(TypeError)
    end
    
    it "should not create a worker if one already exists for the network" do
      handler = IRC::NetworkHandler.new(:nick => 'foo', :networks => {})
      handler.instance_variable_get("@workers")[:EFNet] = 'foo'
      
      IRC::EMWorker.should_not_receive(:connect)
      handler.create_worker(:EFNet, {})
    end
  end
  


end
