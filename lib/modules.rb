class Array
	def random
		self[rand(self.length)]
	end
end
class String
	def random
		self[rand(self.length)].chr
	end

end


module FBSDBot	
  
	module Plugins
	end
	module Helpers
		class NickObfusicator
	
			@NICK_MAX_LEN = 9


			def NickObfusicator.run( old_nick )
				puts old_nick.length
				if old_nick.length < (@NICK_MAX_LEN -1) and old_nick[0] != '|'

					return "|#{old_nick}|"    

				elsif old_nick.length < @NICK_MAX_LEN
					replacements = "\_-|"
					old_nick += replacements.random
					# just add something behind it
					#
				else
					Array.new(@NICK_MAX_LEN) { (rand(122-97) + 97).chr }.join
				end
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

	 class Action

			attr_reader :auth, :nick, :channel, :message, :hostmask, :type
			
			def initialize(bot, auth, event, command = nil)
			@event    = event
			@bot      = bot
			@auth     = auth
			@nick     = nil
			@channel  = nil
			@message  = nil
			@hostmask = nil
			@command  = nil 
			@type     = nil
					
				case event.event_type.to_sym
				when :privmsg

				   @nick = event.from
				   @message = event.message
				   unless event.message.nil?
					  if command
						 @message = event.message.gsub(/!?#{command}/, '').strip
						 @command = command
					  else
						 @message = event.message
						 @command = nil
					  end
				   end
				   @hostmask = event.hostmask

				   # private / public?
				   if event.channel == bot.nick
					  @type       = :privmsg
					  @respond_to = @nick
				   else
					  @type       = :pubmsg
					  @channel    = event.channel
					  @respond_to = @channel
				   end
				when :join
				  @nick        = event.from
				  @hostmask    = event.hostmask
				  @channel     = event.channel
				  @message     = nil
				  @type        = :join
				  @respond_to  = @channel
				when :part
				  @nick         = event.from
				  @hostmask     = event.stats[1]
				  @channel      = event.channel
				  @message      = event.message
				  @type         = :part
				  @respond_to   = @channel
				when :quit
				  @nick         = event.from
				  @hostmask     = event.stats[1]
				  @channel      = event.channel
				  @message      = event.message
				  @type         = :quit
				  @respond_to   = @channel
				end
			end

			def auth?
					self.auth.is_authenticated?(self)
			end

			def reply(msg)
				if @type == :pubmsg
					@bot.send_message(@respond_to, "#{@nick}, #{msg}")
				else
					@bot.send_message(@respond_to, msg)
				end
			end

			def op(channel = @repond_to)
					@bot.op(channel.nil? ? @channel : channel,@nick)
			end

			def join(channel = @respond_to)
					@bot.join(channel)
			end

			def notice(message, to = @respond_to)
					@bot.send_notice(to, message)
			end

			def syntax(msg)
				return reply("Syntax: #{@command} #{msg}") unless @command.nil?
				reply("Syntax: #{msg}")
			end
			
	 end
	 
	 module_function
	 
	 # call with FBSDBot::seconds_to_s etc.
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
	 
  def e_sh(str)
  	str.to_s.gsub(/(?=[^a-zA-Z0-9_.\/\-\x7F-\xFF\n])/, '\\').gsub(/\n/, "'\n'").sub(/^$/, "''")
  end

end

