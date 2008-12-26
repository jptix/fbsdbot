require "rubygems"
require "spec"
require "ruby-debug"
require "#{File.dirname(__FILE__)}/../lib/boot"


include FBSDBot

Debugger.settings[:autoeval] = true
Debugger.settings[:autolist] = 1



