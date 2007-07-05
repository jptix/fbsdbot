

## SYMBOLS
class DuplcatePluginNameError < StandardError
end


class PluginBase
   
   attr_accessor :auth
   def initialize(bot)
      @bot = bot
      @auth = FBSDBot::Authentication.new
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
         elsif name =~ /^hook_join$/
            $hooks_join << method(name.to_sym)
         elsif name =~ /^hook_part$/
            $hooks_part << method(name.to_sym)
         elsif name =~ /^hook_quit$/
            $hooks_quit << method(name.to_sym)
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

   def op(channel,nick)
	   @bot.op(channel,nick)
   end

   def reply(event, msg)

    if event.channel == @bot.nick
     @bot.send_message(event.from, msg)
    else
     @bot.send_message(event.channel, event.from + ': ' + msg)
    end
   end

end
