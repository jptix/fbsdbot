#!/usr/bin/env ruby

$LOAD_PATH << File.expand_path(File.dirname(__FILE__) + '/..')
require 'lib/boot'
require 'lib/options_parser'
require 'lib/irc/event_machine'

EventMachine::run {
  FBSDBot::IRC::EMCore.connect(
  :host     => $config[:host], 
  :nick     => $config[:nick], 
  :realname => $config[:realname] || "FBSDBot",
  :username => $config[:username] || "fbsd",
  :channels => $config[:channels]
  )
  # todo, define errback for handling reconnecting

}

