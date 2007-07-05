

## SYMBOLS
class DuplcatePluginNameError < StandardError
end


class PluginBase
   
   attr_accessor :auth
   def initialize(irc)
      @irc = irc
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
         elsif name =~ /^hook_(.+?)$/
            type = $1
            $bot.hooks[type.to_sym] << method(name.to_sym)
         end
      end
   end

   def register_command(name, method_name)
      cmd = [name, method(method_name.to_sym)]
      if @plugin_commands[name].nil?
         @plugin_commands[name] = cmd
         $bot.commands[name] = cmd
      else
         raise DuplcatePluginNameError, "PluginConflict - command '#{name}' already exists."
      end
   end

   def op(channel,nick)
	   @irc.op(channel,nick)
   end

   def reply(event, msg)

    if event.channel == @irc.nick
     @irc.send_message(event.from, msg)
    else
     @irc.send_message(event.channel, event.from + ': ' + msg)
    end
   end

end
