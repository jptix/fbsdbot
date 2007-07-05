#!/usr/bin/env ruby

require File.dirname(__FILE__) + '/../lib/boot.rb'

module FBSDBot

   class Bot
      attr_accessor :commands, :hooks, :config
      attr_reader :threads, :command_count, :start_time

      def initialize(config)
         @commands = {}
         @command_count = 0

         @config = config
         @start_time = Time.now
         @hooks = {:pubmsg => [], :privmsg => [], :join => [], :part => [], :quit => []}
      end

      def run
         print "Connecting to #{@config['host']}:#{@config['port']}.."
         @irc = IRC.new(@config['nick'], @config['host'], @config['port'], ( @config['ircname'].nil? ? "FBSDBot running on Ruby #{RUBY_VERSION}" : @config['ircname']) )
         IRCEvent.add_callback('nicknameinuse') {|event|	bot.ch_nick( FBSDBot::Helpers::NickObfusicator.run(bot.nick) ) }
         IRCEvent.add_callback('endofmotd') do |event|
            print ".connected!\n"
            load_plugin('corecommands', @irc, (File.dirname(__FILE__) + "/../lib/corecommands.rb"))
            @config['plugins'].each { |plugin| load_plugin(plugin, @irc) }
            @config['channels'].each { |ch| @irc.add_channel(ch); puts "Joined channel: #{ch}"}
            pp @hooks     # DEBUG
         end
         IRCEvent.add_callback('join') { |event| call_hooks(event, :join) }
         IRCEvent.add_callback('part') { |event| call_hooks(event, :part) }
         IRCEvent.add_callback('quit') { |event| call_hooks(event, :quit) }
         IRCEvent.add_callback('privmsg') do |event|
            if event.message =~ /^!.+/ or event.channel == @irc.nick
               line = event.message.sub(/^!/, '').split
               unless @commands[line.first].nil?
                  @command_count += 1
                  @commands[line.shift][1].call(event, line.join(' '))
               end
            end

            if event.channel == @irc.nick
               call_hooks(event, :privmsg)
            else
               call_hooks(event, :pubmsg)
            end
         end
         @irc.connect
      end

      # namespace for Plugins
      module Plugins
      end

      def load_plugin(name, irc, path = nil)
         begin
            n = name.downcase
            Plugins.module_eval { load path || (File.dirname(__FILE__) + "/../plugins/#{n}.rb") }

            if (klass = self.class.const_get(n.capitalize))
               plugin = klass.instantiate(irc)
               puts "Plugin '#{plugin.name.capitalize}' loaded."
            else
               puts "Error loading plugin '#{n.capitalize}':"
               puts "Couldn't locate plugin class. \n Check casing of file and class names (no TitleCase or camelCase allowed)."
            end
         rescue Exception => e
            puts "Error loading core plugin '#{n.capitalize}':"
            puts e.message
            puts e.backtrace.join("\n")
         end
      end

      def call_hooks(event, type)
         @hooks[type].each { |hook| hook.call(event, event.message) }
      end

   end

end

$bot = FBSDBot::Bot.new($config)
$bot.run




