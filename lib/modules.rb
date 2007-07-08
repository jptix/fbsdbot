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
			
			def send_message(to = @respond_to, msg)
			    @bot.send_message(to, msg)
			end

			def op(channel = @respond_to)
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
	    seconds = seconds.round
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
	
	
	# thanks ROR! 
  def distance_of_time_in_words(from_time, to_time = 0, include_seconds = false)
     from_time = from_time.to_time if from_time.respond_to?(:to_time)
     to_time = to_time.to_time if to_time.respond_to?(:to_time)
     distance_in_minutes = (((to_time - from_time).abs)/60).round
     distance_in_seconds = ((to_time - from_time).abs).round

     case distance_in_minutes
     when 0..1
        return (distance_in_minutes == 0) ? 'less than a minute' : '1 minute' unless include_seconds
        case distance_in_seconds
        when 0..4   then 'less than 5 seconds'
        when 5..9   then 'less than 10 seconds'
        when 10..19 then 'less than 20 seconds'
        when 20..39 then 'half a minute'
        when 40..59 then 'less than a minute'
        else             '1 minute'
        end

     when 2..44           then "#{distance_in_minutes} minutes"
     when 45..89          then 'about 1 hour'
     when 90..1439        then "about #{(distance_in_minutes.to_f / 60.0).round} hours"
     when 1440..2879      then '1 day'
     when 2880..43199     then "#{(distance_in_minutes / 1440).round} days"
     when 43200..86399    then 'about 1 month'
     when 86400..525959   then "#{(distance_in_minutes / 43200).round} months"
     when 525960..1051919 then 'about 1 year'
     else                      "over #{(distance_in_minutes / 525960).round} years"
     end
  end
	 
  def e_sh(str)
  	str.to_s.gsub(/(?=[^a-zA-Z0-9_.\/\-\x7F-\xFF\n])/, '\\').gsub(/\n/, "'\n'").sub(/^$/, "''")
  end

end

