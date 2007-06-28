require 'rubygems'
require 'IRC'
require 'yaml'
require File.dirname(__FILE__) + '/modules.rb'

# check for config file
config_file = File.dirname(__FILE__) + '/../bin/towlie.conf'
unless File.exists?( config_file )
	puts "Please create a config-file (YAML syntax) and put it in #{config_file}"
	exit 1
end

@config = YAML.load( File.open(config_file) )
