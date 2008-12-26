require "optparse"
require "yaml"

# defaults
$config = {:port => 6667}
 
op = OptionParser.new do |o|
  
  o.banner = "Usage: #{$0} [options] [config file]"
  
  o.on "-n", "--nick=nick", "A nick to use" do |nick|
    $config['nick'] = nick
  end

  o.on "-h", "--host=host", "An IRC server." do |host|
    $config['host'] = host
  end
  
  o.on "-p", "--port=port", Integer, "A port." do |port|
    $config['port'] = port
  end
  
  o.on "--help", "You're looking at it." do
    abort(o.to_s)
  end
 
end
 
op.parse!(ARGV)

unless ARGV.empty?
  config_file = ARGV.first
  $config.merge(YAML.load_file(config_file))
  puts "Loaded config."
end

p $config


