#!/usr/bin/env ruby

$LOAD_PATH << File.expand_path(File.dirname(__FILE__) + '/..')
require 'lib/boot'
require 'lib/options_parser'

at_exit { FBSDBot::Plugin.run_event(FBSDBot::ShutdownEvent.new) }

manager = FBSDBot::IRC::NetworkHandler.new($config)

EventMachine::run {  
  require 'lib/corecommands'
  require 'lib/partyline'
  require 'lib/authentication'
  Log.info "Loaded plugins:"
  FBSDBot::Plugin.list_plugins
  
  Log.info "Starting Workers:"
  
  manager.create_workers
}

