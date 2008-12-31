require "optparse"
require "yaml"

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

  o.on "-C", "--c-parser", "Use the C parser extension" do
    ENV['BOT_C_EXT'] = '1'
  end
  
  o.on "-c", "--color", "Add colors to the log output" do
    opts[:color] = true
  end
  
  o.on "-d", "--debug", "Show debug output" do
    $DEBUG = true
  end

  o.on "--help", "You're looking at it." do
    abort(o.to_s)
  end

end

op.parse!(ARGV)

config = YAML.load_file(ARGV.first || "#{File.dirname(__FILE__)}/../bin/bot.conf.example")
$config = config.merge(opts)
