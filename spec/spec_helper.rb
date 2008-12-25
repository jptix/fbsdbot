require "rubygems"
require "spec"
require "treetop"
require "ruby-debug"
require "#{File.dirname(__FILE__)}/../lib/irc/parser"
require "#{File.dirname(__FILE__)}/../lib/irc/event"

include FBSDBot

Debugger.settings[:autoeval] = true
Debugger.settings[:autolist] = 1



