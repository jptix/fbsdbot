puts "Starting bot..."
my_path = File.dirname(__FILE__)

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
require 'IRC'
require 'active_record'
require my_path + '/models.rb'
require my_path + '/modules.rb'
require my_path + '/pluginbase.rb'

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
   config_file = File.dirname(__FILE__) + '/../bin/bot.conf'
end

unless File.exists?( config_file )
   puts "Please create a config-file (YAML syntax) and put it in #{config_file}"
   exit 1
end


$config = YAML.load( File.open(config_file) )
puts "Loaded config"



ActiveRecord::Base.establish_connection({
  :adapter => 'sqlite3',
  :dbfile => File.dirname(__FILE__) + '/fbsdbot.db',
})
