require "optparse"
require "yaml"
include FBSDBot::Exceptions

# defaults
opts = {:port => 6667}
 
op = OptionParser.new do |o|
  
  o.banner = "Usage: #{$0} [options] [config file]"
  
  o.on "-n", "--nick=nick", "A nick to use" do |nick|
    opts[:nick] = nick
  end
  
  o.on "-p", "--port=port", Integer, "A port." do |port|
    opts[:port] = port
  end
  
  o.on "--help", "You're looking at it." do
    abort(o.to_s)
  end
 
end
 
op.parse!(ARGV)

config = YAML.load_file(ARGV.first || "#{File.dirname(__FILE__)}/../bin/bot.conf.example")
$config = config.merge(opts)

raise ConfigurationError, "No nick defined in configuration file" if config[:nick].nil?
raise ConfigurationError, "No network defined in configuration file, or not a Hash-class." unless config[:networks].is_a?(Hash)

Log.info "Loaded config."



