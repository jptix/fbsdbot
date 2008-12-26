# CORE
require 'digest/sha1'
require 'pp'
require 'yaml'

# GEMS
require 'rubygems'
require "ruby-debug"
require "eventmachine"

require "lib/logger"
require "lib/action"
require "lib/string"
require 'lib/modules'
require 'lib/hooks'
require 'lib/irc/eventmachine'

Log = FBSDBot::Logger.new