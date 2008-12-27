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
require 'lib/plugin'
require 'lib/irc/parser'
require 'lib/irc/event_producer'

Log = FBSDBot::Logger.new