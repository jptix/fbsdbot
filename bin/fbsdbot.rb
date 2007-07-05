#!/usr/bin/env ruby

	require File.dirname(__FILE__) + '/../lib/boot.rb'
	require File.dirname(__FILE__) + '/../plugins/google2.rb'
  $stdout.sync = true
	$bot = IRC.new(@config['nick'], @config['host'], @config['port'], ( @config['ircname'].nil? ? "FBSDBot running on Ruby #{RUBY_VERSION}" : @config['ircname']) )
	$auth = FBSDBot::Authentication.new
	
	#FBSDBot::Plugin.instance_variable_set("@bot",bot)
	$start_time    = Time.now
	$command_count = 0
	
	# FIRST EVENT
	IRCEvent.add_callback('endofmotd') do |event|
  		puts "connected!"
			puts "Loaded plugins: " 
				pp FBSDBot::Plugin.registered_plugins
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
				if event.channel != $bot.nick
					FBSDBot::Plugin.registered_plugins.each do |ident,p|
							if p.respond_to?("on_pubmsg_#{command}".to_sym)
								p.send("on_pubmsg_#{command}".to_sym, event, line)
								# exit ? 
							# else plugin cant handle "def on_pubmsg_<command>(event, line)"
							end
					end
				else # PRIVATE
					FBSDBot::Plugin.registered_plugins.each do |ident,p|
							if p.respond_to?("on_pubmsg_#{command}".to_sym)
								p.send("on_pubmsg_#{command}".to_sym, event, line)
								# exit ? 
							# else plugin cant handle "def on_pubmsg_<command>(event, line)"
							end
					end
				end
			end
	end
	# CONNECT
	$bot.connect
	exit

	# NOOOOOOOOOOOOOOOOTHING HAPPENS HERE

