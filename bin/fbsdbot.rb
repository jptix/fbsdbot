#!/usr/bin/env ruby

	require File.dirname(__FILE__) + '/../lib/boot.rb'
  $stdout.sync = true

  print "Connecting to #{@config['host']}:#{@config['port']}.."

	bot = IRC.new(@config['nick'], @config['host'], @config['port'], ( @config['ircname'].nil? ? "FBSDBot running on Ruby #{RUBY_VERSION}" : @config['ircname']) )
	
	# global maps
	#$commands      = {}
	#$start_time    = Time.now
	#$command_count = 0
	
	#$hooks_pubmsg  = []
	#$hooks_privmsg = []
	#$hooks_join    = []
	#$hooks_part    = []
	#$hooks_quit    = []
	#

	IRCEvent.add_callback('endofmotd') do |event|
  		puts "connected!"
			FBSDBot::Plugin.registered_plugins.each do |ident,p|
				puts "loaded plugin: #{ident} (#{p.version}) by #{p.author} - handles: #{p.handles}"
				if p.respond_to?(:do_it)
					puts p.do_it(2) 
				end
			end
	end
	bot.connect
	exit

	#IRCEvent.add_callback('nicknameinuse') {|event|	bot.ch_nick( FBSDBot::Helpers::NickObfusicator.run(bot.nick) ) }
	IRCEvent.add_callback('endofmotd') do |event|
  		puts "connected!"
  		hooks.load_plugin('corecommands', bot, (File.dirname(__FILE__) + "/../lib/corecommands.rb"))
    	#@config['plugins'].each { |plugin| hooks.load_plugin(plugin, bot) }
  		#@config['channels'].each { |ch| bot.add_channel(ch); puts "Joined channel: #{ch}"}
	end
	$stdout.sync = false
	IRCEvent.add_callback('join') { |event| hooks.call_hooks(event, :join) }
	IRCEvent.add_callback('part') { |event| hooks.call_hooks(event, :part) }
	IRCEvent.add_callback('quit') { |event| hooks.call_hooks(event, :quit) }
	IRCEvent.add_callback('privmsg') do |event| 
			if event.message =~ /^!.+/ or event.channel == bot.nick
			  line = event.message.sub(/^!/, '').split
			  unless hooks.commands[line.first].nil?
			    $command_count += 1
			    hooks.commands[line.shift][1].call(event, line.join(' '))
			  end
			end
			
			if event.channel == bot.nick
			  hooks.call_hooks(event, :privmsg)
			else
			  hooks.call_hooks(event, :pubmsg)
      end
	end

  bot.connect
