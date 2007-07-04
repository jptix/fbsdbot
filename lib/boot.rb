# UTF-8
$KCODE = 'u'
require 'jcode'

require 'digest/sha1'
require 'pp'
require 'yaml'
require 'rubygems'
require 'IRC'
require 'active_record'
require 'htmlentities'
require File.dirname(__FILE__) + '/models.rb'
require File.dirname(__FILE__) + '/modules.rb'
require File.dirname(__FILE__) + '/pluginbase.rb'

# check for config file 
# FIXME: should use OptionParser or similar in the future
if ARGV.size > 0
   config_file = File.expand_path(ARGF.file.path) 
else
   config_file = File.dirname(__FILE__) + '/../bin/bot.conf'
end

unless File.exists?( config_file )
   puts "Please create a config-file (YAML syntax) and put it in #{config_file}"
   exit 1
end


@config = YAML.load( File.open(config_file) )
puts "Loaded config"

ActiveRecord::Base.establish_connection({
  :adapter => 'sqlite3',
  :dbfile => File.dirname(__FILE__) + '/fbsdbot.db',
})
