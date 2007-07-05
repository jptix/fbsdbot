
def seconds_to_s(seconds)
   s = seconds % 60
   m = (seconds /= 60) % 60
   h = (seconds /= 60) % 24
   d = (seconds /= 24)
   out = []
   out << "#{d}d" if d > 0
   out << "#{h}h" if h > 0
   out << "#{m}m" if m > 0
   out << "#{s}s" if s > 0
   out.length > 0 ? out.join(' ') : '0s'
end

# namespace for plugins
module Plugins
end

def load_plugin(name, bot, path = nil)
   begin
      n = name.downcase
      Plugins.module_eval { load path || (File.dirname(__FILE__) + "/../plugins/#{n}.rb") }

      if (klass = self.class.const_get(n.capitalize))
         plugin = klass.instantiate(bot)
         puts "Plugin '#{plugin.name.capitalize}' loaded."
      else
         puts "Error loading plugin '#{n.capitalize}':"
         puts "Couldn't locate plugin class. \n Check casing of file and class names (no TitleCase or camelCase allowed)."
      end
   rescue Exception => e
      puts "Error loading core plugin '#{n.capitalize}':"
      puts e.message
      puts e.backtrace.join("\n")
   end

end

$htmlentities = HTMLEntities.new
class String; def decode_entities; return $htmlentities.decode(self); end; end


def call_hooks(event, type)
  case type
  when :pubmsg
    $hooks_pubmsg.each { |hook| hook.call(event, event.message) }
  when :privmsg
    $hooks_privmsg.each { |hook| hook.call(event, event.message) }
  end
  
  
end
