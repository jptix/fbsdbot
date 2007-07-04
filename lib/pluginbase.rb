

## SYMBOLS
"event_public".to_sym
"event_private".to_sym

class DuplcatePluginNameError < StandardError
end

class PluginBase
   
   def initialize(bot)
      @bot = bot
      @plugin_commands = {}
      register_commands
      
   end

   def PluginBase.instantiate(bot)
       @instance ||= self.new(bot)
   end
   
   def name
       @name ||= self.class.name.downcase
    end

   def register_commands
      self.class.instance_methods(false).each do |name|
         if name =~ /^cmd_(.+)$/
            register_command($1, name)
         elsif name =~ /^hook_pubmsg$/
            $hooks_pubmsg << method(name.to_sym)
         elsif name =~ /^hook_privmsg$/
            $hooks_privmsg << method(name.to_sym)
         end
      end
   end

   def register_command(name, method_name)
      cmd = [name, method(method_name.to_sym)]
      if @plugin_commands[name].nil?
         @plugin_commands[name] = cmd
         $commands[name] = cmd
      else
         raise DuplcatePluginNameError, "PluginConflict - command '#{name}' already exists."
      end
   end

   def reply(event, msg)

    if event.channel == @bot.nick
     @bot.send_message(event.from, msg)
    else
     @bot.send_message(event.channel, event.from + ': ' + msg)
    end
   end

end
