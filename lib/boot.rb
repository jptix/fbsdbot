require 'digest/sha1'
require 'pp'
require 'yaml'
require 'rubygems'
require 'IRC'
require 'active_record'
$KCODE = 'u'
require 'jcode'
require File.dirname(__FILE__) + '/models.rb'
require File.dirname(__FILE__) + '/modules.rb'
require File.dirname(__FILE__) + '/pluginbase.rb'

# check for config file 
# FIXME: should use OptionParser or similar in the future
if ARGV.size > 0
   config_file = File.dirname(__FILE__) + "/../bin/#{ARGV[0]}"
else
   config_file = File.dirname(__FILE__) + '/../bin/bot.conf'
end

unless File.exists?( config_file )
   puts "Please create a config-file (YAML syntax) and put it in #{config_file}"
   exit 1
end


@config = YAML.load( File.open(config_file) )
puts "Loaded config"

db_file = File.dirname(__FILE__) + '/fbsdbot.db'

ActiveRecord::Base.establish_connection({
  :adapter => 'sqlite3',
  :dbfile => db_file,
})
