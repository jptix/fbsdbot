require "rubygems"
require "spec"
require "treetop"
require "ruby-debug"
require "#{File.dirname(__FILE__)}/../lib/irc/parser"
require "#{File.dirname(__FILE__)}/../lib/irc/event"
require "#{File.dirname(__FILE__)}/../lib/irc/event_producer"

include FBSDBot

Debugger.settings[:autoeval] = true
Debugger.settings[:autolist] = 1



