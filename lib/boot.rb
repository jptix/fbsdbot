# CORE
require 'digest/sha1'
require 'pp'
require 'yaml'

# GEMS
require 'rubygems'
require "eventmachine"

require "lib/logger"
require "lib/string"
require 'lib/modules'
require 'lib/hooks'
require 'lib/auth'
require 'lib/irc/parser'
require 'lib/irc/event_producer'

Log = FBSDBot::Logger.new