

## SYMBOLS
class DuplcatePluginNameError < StandardError
end

module FBSDBot
	class Authentication
		def initialize
			@authenticated = {}
		end
		
		def authenticate(event,handle,password)
			u = User.find(:first, :include => [:hosts], :conditions => ['handle = ?',handle])
			return false if u.nil?
			
			#got user, now check pw
			return false unless u.check_password(password)
			
			# XXX: TODO, fix matching of hostmask against user, not just pass			
			@authenticated[event.from.to_sym] = AuthenticatedUser.new(event,u)
			true
		end
		
		def is_authenticated?(event)
			a = @authenticated[event.from.to_sym]
			if a.nil?
				return false
			elsif a.host_changed?(event.hostmask)
				@authenticated.delete(event.from.to_sym)
				return false
			end
			true
		end

		def logout(event)
			a = @authenticated[event.from.to_sym]
			@authenticated.delete(event.from.to_sym) unless a.nil?
			true
		end

		def mapuser(event)
			@authenticated[event.from.to_sym]
		end
		
	end
	
	private
	class AuthenticatedUser
		attr_reader :login_date, :event, :idle_since, :user

		def initialize(event,u)
			@event = event
			@user = u
			@login_date = Time.now
		end

		def host_changed?(host)
			host == @event.hostmask ? false : true
		end
		
	end
	
	module Helpers
		class NickObfusicator
			def NickObfusicator.run( old_nick )
				# find stuff to replace
				new_nick = old_nick
				nick_map = { "a" => "4", "l" => "1", "o" => "0", "e" => "3" } 
	
				candidates = old_nick.scan(/([aloe])/)
				other_options = ["-","_"]
	
				i_replacements = 0
	
				if candidates.size > 0
					candidates = candidates.uniq 
					candidates.each {|c| new_nick = new_nick.to_s.sub("a", nick_map["a"]); i_replacements += 1 }
				end
			
				if i_replacements == 0
					new_nick += other_options[rand((other_options.size) -1)]
					i_replacements += 1
				end
				new_nick
			end
		end
		class Hostmask
		attr :exp
		def initialize(hostmask)
			@hostmask = hostmask
		end
		def match(exp)
			@exp = Regexp.new("^" + exp.gsub('*','.+?') + "$")
			return true	if( @exp.match(@hostmask) )
			false
		end
		end
	end
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
