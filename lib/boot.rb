puts "Starting bot..."

# UTF-8
$KCODE = 'u'
require 'jcode'

# CORE
require 'digest/sha1'
require 'pp'
require 'yaml'
require 'ostruct'
require 'optparse'

# GEMS
require 'rubygems'
require 'active_record'
require "treetop"
require "ruby-debug"

require "lib/action"
require 'lib/models'
require 'lib/modules'
require 'lib/hooks'
#require my_path + '/pluginbase'
require 'lib/auth'
require "lib/irc/connection"

# Default Options
#options = OpenStruct.new
#options.config_file =  my_path + '/../bin/bot.conf'

#opt = OptionParser.new do |opt|
#	opt.banner = "Usage: #{$0} [options]"
#	opt.on("-c","--config FILE", "optional config file") do |c|
#		unless File.exists?(c)
#			puts "Config file #{c} dosn't exist"
#			exit 1
#		end
#		options.config_file = c
#	end
#end

if ARGV.size > 0
  config_file = File.expand_path(ARGF.file.path)
else
  config_file = $botdir + 'bin/bot.conf'
end

unless File.exists?( config_file )
  puts "Please create a config-file (YAML syntax) and put it in #{config_file}"
  exit 1
end


$config = YAML.load( File.open(config_file) )
puts "Loaded config."



ActiveRecord::Base.establish_connection({
  :adapter => 'sqlite3',
  :dbfile => $botdir + 'bin/fbsdbot.db',
})
