require "optparse"
require "yaml"

# defaults
opts = {:port => 6667}
 
op = OptionParser.new do |o|
  
  o.banner = "Usage: #{$0} [options] [config file]"
  
  o.on "-n", "--nick=nick", "A nick to use" do |nick|
    opts[:nick] = nick
  end

  o.on "-h", "--host=host", "An IRC server." do |host|
    opts[:host] = host
  end
  
  o.on "-p", "--port=port", Integer, "A port." do |port|
    opts[:port] = port
  end
  
  o.on "--help", "You're looking at it." do
    abort(o.to_s)
  end
 
end
 
op.parse!(ARGV)

<<<<<<< HEAD:lib/options_parser.rb
unless ARGV.empty?
  config_file = ARGV.first
  $config.merge!(YAML.load_file(config_file))
  puts "Loaded config."
end
=======
config = YAML.load_file(ARGV.first || "#{File.dirname(__FILE__)}/../bin/bot.conf.example")
$config = config.merge(opts)
puts "Loaded config."
>>>>>>> eff663b9ac015641e67a7169a95f7927bfaa5457:lib/options_parser.rb

p $config


