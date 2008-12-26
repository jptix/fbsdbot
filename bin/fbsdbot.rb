#!/usr/bin/env ruby

 
$LOAD_PATH << File.expand_path(File.dirname(__FILE__) + '/..')
require 'lib/boot'
require "lib/options_parser" # creates $config


module FBSDBot

  VERSION = "0.1"

  class Bot
    attr_accessor :commands, :hooks, :nick, :auth, :command_count
    attr_reader :threads, :start_time

    def initialize(config)
      @commands = []
      @command_count = 0

      @config = config
      @nick = @config[:nick]
      @host = @config[:host]
      @port = @config[:port]
      @ircname = @config[:ircname].nil? ? "FBSDBot running on Ruby #{RUBY_VERSION}" : @config['ircname']

      @start_time = Time.now
      puts "Starting bot..."
      
      @auth = FBSDBot::Authentication.new
      load_plugins
    end

    def run
      $stdout.sync = true
      @irc = IRC::Connection.new(@nick, @host, :port => @port, :real_name => @ircname )
      @irc.add_callback(:nickname_in_use) {|event|	@irc.ch_nick( FBSDBot::Helpers::NickObfusicator.run(@irc.nick) ) }
      @irc.add_callback(:end_of_motd) do |event|
        @config['channels'].each do |ch|
          @irc.join_channel(ch)
          puts "Joined channel: #{ch}"
        end
      end
      $stdout.sync = false

      @irc.add_callback(:private_message) do |event|
        if event.message[0] == 001
          FBSDBot::Plugin.find_plugins("on_ctcp_#{action.message}".to_sym, event)
        elsif event.message =~ /^!(\S+)/ or event.nick == @irc.nick
          command = event.message.sub(/^!/, '').split[0]
          return if command.nil?
          FBSDBot::Plugin.find_plugins("on_msg_#{command}".to_sym, event)
        else
          FBSDBot::Plugin.find_plugins("on_msg".to_sym, event )
        end
      end


      @irc.add_callback(:join) {|event| FBSDBot::Plugin.find_plugins(:on_join, event) }
      @irc.add_callback(:part) {|event| FBSDBot::Plugin.find_plugins(:on_part, event) }
      @irc.add_callback(:quit) {|event| FBSDBot::Plugin.find_plugins(:on_quit, event) }

      @irc.connect
      @irc.join
    end

    private
    def load_plugins
      require 'lib/corecommands'
      (Dir.entries($botdir + 'plugins-active') - ['.', '..']).each { |file| require 'plugins-active/' + file } if File.exists?('plugins-active')
      puts "Loaded plugins: "
      FBSDBot::Plugin.list_plugins
      FBSDBot::Plugin.registered_plugins.each do |ident,p|
        p.commands ? @commands += p.commands : nil
      end
      @commands.flatten!
    end

  end # class FBSDBot::Bot
end # module FBSDBot

begin
  $bot = FBSDBot::Bot.new($config)
  $bot.run
ensure
  puts "\nShutting down."
  FBSDBot::Plugin.registered_plugins.each do |ident,p|
    if p.respond_to?(:on_shutdown)
      p.send(:on_shutdown)
    end
  end
end
