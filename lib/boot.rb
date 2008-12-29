# CORE
require 'digest/sha1'
require 'pp'
require 'yaml'

# GEMS
require 'rubygems'
require 'eventmachine'

require 'lib/logger'
require 'lib/core_ext/array'
require 'lib/core_ext/string'
require 'lib/core_ext/boolean'
require 'lib/exceptions'
require 'lib/helpers'
require 'lib/plugin'

require 'lib/irc/network_handler'
require 'lib/irc/event_producer'
require 'lib/irc/parser'


Log = FBSDBot::Logger.new
Log.level = $DEBUG ? :debug : :info

module FBSDBot
  VERSION = "0.1"
end

