# CORE
require 'digest/sha1'
require 'pp'
require 'yaml'

# GEMS
require 'rubygems'
require "ruby-debug"

require "lib/logger"
require "lib/action"
require "lib/string"
require 'lib/modules'
require 'lib/hooks'
#require 'lib/pluginbase'
require 'lib/auth'
require "lib/irc/connection"

Log = FBSDBot::Logger.new