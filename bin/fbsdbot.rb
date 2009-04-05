#!/usr/bin/env ruby
# encoding: utf-8


$LOAD_PATH << File.expand_path(File.dirname(__FILE__) + '/..')
require 'lib/options_parser'
require 'lib/boot'

Log.level = $DEBUG ? :debug : :info
Log.color = $config[:color]


manager = FBSDBot::IRC::NetworkHandler.new($config)
at_exit do
  FBSDBot::Plugin.run_event(FBSDBot::ShutdownEvent.new)
  [$stdout, $stderr].each { |io| io.flush }
end


EventMachine::run {
  ($config[:plugins] || []).each {|p| require "plugins/#{p}.rb" }
  require 'lib/corecommands'
  require 'lib/partyline'
  require 'lib/authentication'
  Log.info "Loaded plugins:"
  FBSDBot::Plugin.list_plugins

  Log.info "Starting Workers:"

  manager.create_workers
}
