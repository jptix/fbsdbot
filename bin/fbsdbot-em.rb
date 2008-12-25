#!/usr/bin/env ruby

$botdir = File.expand_path(File.dirname(__FILE__) + '/..') + '/'
$LOAD_PATH << $botdir
require 'lib/boot'


EventMachine::run {
  irc = EventMachine::Protocols::IrcClient.connect(
      :host     => "irc.daxnet.no", 
      :nick     => "WorkBond", 
      :realname => "FBSDBot", 
      :username => "db")
      
  irc.callback {|message|
    puts "got a message from server: #{message}"
  }
  
}

