#!/usr/bin/env ruby
$: << File.dirname(__FILE__) + '/../plugins/'
require File.dirname(__FILE__) + '/../lib/boot.rb'
require File.dirname(__FILE__) + '/../plugins/google2.rb'
require File.dirname(__FILE__) + '/../plugins/auth.rb'

module FBSDBot


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
        $: << 
        @config['plugins'].each { |p| require p }
      end
      
   end # class FBSDBot::Bot
end # module FBSDBot

$bot = FBSDBot::Bot.new($config)
$bot.run
