#!/usr/bin/env ruby

require File.dirname(__FILE__) + '/../lib/boot.rb'
$plugins_active = File.dirname(__FILE__) + '/../plugins-active/'
$: << $plugins_active

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
            if event.message =~ /^(\S+)/ or event.channel == @irc.nick
               command = event.message.sub(/^!/, '').split[0]
							 return if command.nil?
               FBSDBot::Plugin.registered_plugins.each do |ident,p|
                  if p.respond_to?("on_msg_#{command}".to_sym)
                     p.send("on_msg_#{command}".to_sym, Action.new(@irc,@auth, event))
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
