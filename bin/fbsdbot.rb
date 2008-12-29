#!/usr/bin/env ruby

$LOAD_PATH << File.expand_path(File.dirname(__FILE__) + '/..')
require 'lib/boot'
require 'lib/options_parser'

Log.level = $DEBUG ? :debug : :info

module FBSDBot
  VERSION = "0.1"
end


manager = FBSDBot::IRC::NetworkHandler.new($config)


EventMachine::run {  
  require 'lib/corecommands'
  Log.info "Loaded plugins:"
  FBSDBot::Plugin.list_plugins
  
  Log.info "Starting Workers:"
  
  manager.create_workers
}

