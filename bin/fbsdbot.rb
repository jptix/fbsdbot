#!/usr/bin/env ruby

$botdir = File.expand_path(File.dirname(__FILE__) + '/..') + '/'
$LOAD_PATH << $botdir
require 'lib/boot.rb'


module FBSDBot

  VERSION = "0.1"

  class Bot
    attr_accessor :commands, :hooks, :nick, :auth, :command_count
    attr_reader :threads, :start_time

    def initialize(config)
      @commands = []
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
        @config['channels'].each do |ch|
          @irc.add_channel(ch)
          puts "Joined channel: #{ch}"
        end
      end
      $stdout.sync = false

      # MESSAGES
      IRCEvent.add_callback('privmsg') do |event|
        if event.message[0] == 001
          action = Action.new(@irc,@auth,event)
          FBSDBot::Plugin.find_plugins("on_ctcp_#{action.message}".to_sym, action)
        elsif event.message =~ /^!(\S+)/ or event.channel == @irc.nick
          command = event.message.sub(/^!/, '').split[0]
          return if command.nil?
          action = Action.new(@irc,@auth,event, command)
          FBSDBot::Plugin.find_plugins("on_msg_#{command}".to_sym, action)
        else
          FBSDBot::Plugin.find_plugins("on_msg".to_sym, Action.new(@irc,@auth,event) )
        end
      end


      # JOIN
      IRCEvent.add_callback('join') {|event| FBSDBot::Plugin.find_plugins(:on_join, Action.new(@irc, @auth, event)) }
      # PART
      IRCEvent.add_callback('part') {|event| FBSDBot::Plugin.find_plugins(:on_part, Action.new(@irc, @auth, event)) }
      # QUIT
      IRCEvent.add_callback('quit') {|event| FBSDBot::Plugin.find_plugins(:on_quit, Action.new(@irc, @auth, event)) }

      @irc.connect
    end

    private
    def load_plugins
      require 'lib/corecommands.rb'
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
    if p.respond_to?("on_shutdown".to_sym)
      p.send("on_shutdown".to_sym)
    end
  end
end
