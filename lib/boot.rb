puts "Starting bot..."

# CORE

require 'digest/sha1'
require 'pp'
require 'yaml'

# GEMS
require 'rubygems'
require "treetop"
require "ruby-debug"
require "eventmachine"

require "lib/action"
require 'lib/modules'
require 'lib/hooks'
#require 'lib/pluginbase'
#require 'lib/auth'
require 'lib/irc/eventmachine.rb'

config_file = (ARGV.size > 0) ? File.expand_path(ARGF.file.path) : $botdir + 'bin/bot.conf'

unless File.exists?( config_file )
  puts "Please create a config-file (YAML syntax) and put it in #{config_file}"
  exit 1
end


$config = YAML.load( File.open(config_file) )
puts "Loaded config."
