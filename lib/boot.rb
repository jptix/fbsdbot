# CORE
require 'digest/sha1'
require 'pp'
require 'yaml'

# GEMS
require 'rubygems'
require "eventmachine"

require "lib/logger"
require "lib/core_ext/string"
require 'lib/helpers'
require 'lib/plugin'
require 'lib/irc/parser'
require 'lib/irc/event_producer'
require 'lib/bitmask'
require 'lib/user'
require 'lib/yaml_user_store'

Log = FBSDBot::Logger.new