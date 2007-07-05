#!/usr/bin/env ruby

	require File.dirname(__FILE__) + '/../lib/boot.rb'
  $stdout.sync = true

  print "Connecting to #{@config['host']}:#{@config['port']}.."

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

	end

	# MESSAGES
	IRCEvent.add_callback('privmsg') do |event| 
			if event.message =~ /^!.+/ or event.channel == $bot.nick
			  line = event.message.sub(/^!/, '').split
				command = line.shift

				if event.channel == $bot.nick
					type = :privmsg
				else 
					type = :pubmsg
				end

				FBSDBot::Plugin.registered_plugins.each do |ident,p|
						$bot.send_message(event.channel, "pub message")
						if p.respond_to?("on_pubmsg_#{command}".to_sym)
							$bot.send_message(event.channel, "plugin #{ident} can do 'on_pubmsg_#{command}'")
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

	#IRCEvent.add_callback('nicknameinuse') {|event|	bot.ch_nick( FBSDBot::Helpers::NickObfusicator.run(bot.nick) ) }
	IRCEvent.add_callback('endofmotd') do |event|
  		puts "connected!"
  		hooks.load_plugin('corecommands', bot, (File.dirname(__FILE__) + "/../lib/corecommands.rb"))
    	#@config['plugins'].each { |plugin| hooks.load_plugin(plugin, bot) }
	end
	$stdout.sync = false
	IRCEvent.add_callback('join') { |event| hooks.call_hooks(event, :join) }
	IRCEvent.add_callback('part') { |event| hooks.call_hooks(event, :part) }
	IRCEvent.add_callback('quit') { |event| hooks.call_hooks(event, :quit) }
			  unless hooks.commands[line.first].nil?
			    $command_count += 1
			    hooks.commands[line.shift][1].call(event, line.join(' '))
			  end
			#end
			
			if event.channel == bot.nick
			  hooks.call_hooks(event, :privmsg)
			else
			  hooks.call_hooks(event, :pubmsg)
      end
	#end

  bot.connect
