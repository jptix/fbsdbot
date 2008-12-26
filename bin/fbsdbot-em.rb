#!/usr/bin/env ruby

$botdir = File.expand_path(File.dirname(__FILE__) + '/..') + '/'
$LOAD_PATH << $botdir
require 'lib/boot'

EventMachine::run {
  FBSDBot::IRC::EMCore.connect(
  :host     => $config[:host], 
  :nick     => $config[:nick], 
  :realname => $config[:realname] || "FBSDBot",
  :username => $config[:username] || "fbsd")
  # todo, define errback for handling reconnecting

}

