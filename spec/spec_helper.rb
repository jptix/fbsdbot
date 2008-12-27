require "rubygems"
require "spec"
require "#{File.dirname(__FILE__)}/../lib/boot"

begin
  require "ruby-debug"
  Debugger.settings[:autoeval] = true
  Debugger.settings[:autolist] = 1
rescue LoadError
  puts "install ruby-debug if you want to use the debugger"
end

include FBSDBot

Log.level = :fatal


def parse_message(string)
  res = IRC::Parser.parse_message(string)
  res.should_not be_empty
  res
end
