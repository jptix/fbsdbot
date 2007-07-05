#!/usr/bin/env ruby

require File.dirname(__FILE__) + '/../lib/boot.rb'
$plugins_active = File.dirname(__FILE__) + '/../plugins-active/'
$: << $plugins_active

module FBSDBot

	 class Action

#<IRCEvent:0xb77a58ac
# @channel="#bot-test.no",
# @event_type="privmsg",
# @from="Mr_Bond",
# @hostmask="d@niel.no",
# @message="!auth",
# @stats=["Mr_Bond", "d@niel.no", "PRIVMSG", "#bot-test.no"],
# @user=#<IRCUser:0xb77a571c @username="Mr_Bond">>


			attr_reader :nick, :channel, :message, :hostmask
			
			def initialize(bot,event)
				@bot = bot
				@nick = nil
				@channel = nil
				@message = nil
				@hostmask = nil
					
				case event.event_type.to_sym
					when :privmsg
						
						@nick = event.from
						@message = event.message.gsub(/!\S+/,'').strip unless(event.message.nil?)
						@hostmask = event.hostmask

						# private / public?
						if event.channel == bot.nick
							@type = :privmsg
							@respond_to = @nick
						else
							@type = :pubmsg
							@channel = event.channel
							@respond_to = @channel
					  end	
				end
			end

			def reply(msg)
				if @type == :privmsg
					@bot.send_message(@respond_to, msg)
				elsif @type == :pubmsg
					@bot.send_message(@respond_to, "#{@nick}, #{msg}")
				end
			end
			
	 end

   class Bot
      attr_accessor :commands, :hooks, :config, :irc, :auth
      attr_reader :threads, :command_count, :start_time

      def initialize(config)
         @commands = {}
         @command_count = 0

         @config = config
         @start_time = Time.now
         @auth = FBSDBot::Authentication.new
         load_plugins
      end

      def run
         $stdout.sync = true
         print "Connecting to #{@config['host']}:#{@config['port']}.."
         @irc = IRC.new(@config['nick'], @config['host'], @config['port'], ( @config['ircname'].nil? ? "FBSDBot running on Ruby #{RUBY_VERSION}" : @config['ircname']) )
         IRCEvent.add_callback('nicknameinuse') {|event|	bot.ch_nick( FBSDBot::Helpers::NickObfusicator.run(bot.nick) ) }
         # FIRST EVENT
         IRCEvent.add_callback('endofmotd') do |event|
            puts "connected!"
            puts "Loaded plugins: "
						FBSDBot::Plugin.list_plugins
            @config['channels'].each do |ch|
               @irc.add_channel(ch)
               puts "Joined channel: #{ch}"
            end
         end
         $stdout.sync = false
         
         # MESSAGES
         IRCEvent.add_callback('privmsg') do |event|
            if event.message =~ /^!.+/ or event.channel == @irc.nick
               line = event.message.sub(/^!/, '').split
               command = line.shift
               if event.channel != @irc.nick
                  FBSDBot::Plugin.registered_plugins.each do |ident,p|
                     if p.respond_to?("on_pubmsg_#{command}".to_sym)
                        p.send("on_pubmsg_#{command}".to_sym, Action.new(@irc,@auth, event))
                     end
                  end
               else # PRIVATE
                  FBSDBot::Plugin.registered_plugins.each do |ident,p|
                     if p.respond_to?("on_privmsg_#{command}".to_sym)
                        p.send("on_privmsg_#{command}".to_sym, Action.new( @irc,@auth, event ))
                     end
                  end
               end
            end
         end
         @irc.connect
      end
      
			private
      def load_plugins
        Dir.entries($plugins_active).each { |file| require file unless ['.', '..'].include?(file) }
      end
      
   end # class FBSDBot::Bot
end # module FBSDBot

$bot = FBSDBot::Bot.new($config)
$bot.run
