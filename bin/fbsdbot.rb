#!/usr/bin/env ruby

	require File.dirname(__FILE__) + '/../lib/boot.rb'
  $stdout.sync = true
	$bot = IRC.new(@config['nick'], @config['host'], @config['port'], ( @config['ircname'].nil? ? "FBSDBot running on Ruby #{RUBY_VERSION}" : @config['ircname']) )
	
	#FBSDBot::Plugin.instance_variable_set("@bot",bot)
	$start_time    = Time.now
	$command_count = 0
	
	# FIRST EVENT
	IRCEvent.add_callback('endofmotd') do |event|
  		puts "connected!"
  			@config['channels'].each do |ch| 
						$bot.add_channel(ch)
					  puts "Joined channel: #{ch}"
				end
	end
	

	# MESSAGES
	IRCEvent.add_callback('privmsg') do |event| 
			if event.message =~ /^!.+/ or event.channel == $bot.nick
			  line = event.message.sub(/^!/, '').split
				command = line.shift
				FBSDBot::Plugin.registered_plugins.each do |ident,p|
						$bot.send_message(event.channel, "pub message")
						if p.respond_to?("on_pubmsg_#{command}".to_sym)
							p.send("on_pubmsg_#{command}".to_sym, event)
						else
							$bot.send_message(event.channel, "plugin #{ident} can't do 'on_pubmsg_#{command}'")
						end
				end
	end
	end
	# CONNECT
	$bot.connect
	exit

	# NOOOOOOOOOOOOOOOOTHING HAPPENS HERE

