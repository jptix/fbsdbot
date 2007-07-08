#!/usr/bin/env ruby

require File.dirname(__FILE__) + '/../lib/boot.rb'
$plugins_active = File.dirname(__FILE__) + '/../plugins-active/'
$: << $plugins_active

module FBSDBot

   class Bot
      attr_accessor :commands, :hooks, :nick, :auth
      attr_reader :threads, :command_count, :start_time

      def initialize(config)
         @commands = {}
         @command_count = 0

         @config = config
         @nick = @config['nick']
         @host = @config['host']
         @port = @config['port']
         @ircname = @config['ircname'].nil? ? "FBSDBot running on Ruby #{RUBY_VERSION}" : @config['ircname']

         @start_time = Time.now
         @auth = FBSDBot::Authentication.new
         load_plugins
      end

      def run
         $stdout.sync = true
         print "Connecting to #{@config['host']}:#{@config['port']}.."
         @irc = IRC.new(@nick, @host, @port, @ircname )
         IRCEvent.add_callback('nicknameinuse') {|event|	@irc.ch_nick( FBSDBot::Helpers::NickObfusicator.run(@irc.nick) ) }
         # FIRST EVENT
         IRCEvent.add_callback('endofmotd') do |event|
            puts "connected!"
            puts "Loaded plugins: "
            @config['channels'].each do |ch|
               @irc.add_channel(ch)
               puts "Joined channel: #{ch}"
            end
         end
         $stdout.sync = false
         
         # MESSAGES
         IRCEvent.add_callback('privmsg') do |event|
            if event.message =~ /^!(\S+)/ or event.channel == @irc.nick
               command = event.message.sub(/^!/, '').split[0]
							 return if command.nil?
               FBSDBot::Plugin.registered_plugins.each do |ident,p|
                  if p.respond_to?("on_msg_#{command}".to_sym)
                     @command_count += 1
                     p.send("on_msg_#{command}".to_sym, Action.new(@irc,@auth, event, command))
                  end
									if p.respond_to?('on_msg')
										 p.send("on_msg", Action.new(@irc,@auth, event))
                  end
               end
            else 
              FBSDBot::Plugin.registered_plugins.each do |ident,p|
									if p.respond_to?('on_msg')
										 p.send("on_msg", Action.new(@irc,@auth, event))
                 end
              end
            end
         end
         
         # JOIN
         IRCEvent.add_callback('join') do |event|
            FBSDBot::Plugin.registered_plugins.each do |ident,p|
               if p.respond_to?("on_join".to_sym)
                  p.send("on_join".to_sym, Action.new(@irc, @auth, event))
               end
            end
         end
         
         IRCEvent.add_callback('part') do |event|
            FBSDBot::Plugin.registered_plugins.each do |ident,p|
               if p.respond_to?("on_part".to_sym)
                  p.send("on_part".to_sym, Action.new(@irc, @auth, event))
               end
            end
         end

         IRCEvent.add_callback('quit') do |event|
            FBSDBot::Plugin.registered_plugins.each do |ident,p|
               if p.respond_to?("on_quit".to_sym)
                  p.send("on_quit".to_sym, Action.new(@irc, @auth, event))
               end
            end
         end
               
         @irc.connect
      end
      
			private
      def load_plugins
        require $plugins_active + '/../lib/corecommands.rb'
        Dir.entries($plugins_active).each { |file| require $plugins_active + file unless ['.', '..'].include?(file) }
        FBSDBot::Plugin.list_plugins
      end
      
   end # class FBSDBot::Bot
end # module FBSDBot

begin
  $bot = FBSDBot::Bot.new($config)
  $bot.run
ensure
  puts "\nShutting down."
   FBSDBot::Plugin.registered_plugins.each do |ident,p|
      if p.respond_to?("on_shutdown".to_sym)
         p.send("on_shutdown".to_sym)
      end
   end
end