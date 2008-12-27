require "rubygems"
require "spec"
require "ruby-debug"
require "#{File.dirname(__FILE__)}/../lib/boot"


include FBSDBot

Log.level = :fatal

Debugger.settings[:autoeval] = true
Debugger.settings[:autolist] = 1


def parse_message(string)
  res = IRC::Parser.parse_message(string)
  res.should_not be_empty
  res
end
