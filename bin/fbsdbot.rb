#!/usr/bin/env ruby

	require File.dirname(__FILE__) + '/../lib/boot.rb'
  $stdout.sync = true

  print "Connecting to #{@config['host']}:#{@config['port']}.."

	bot = IRC.new(@config['nick'], @config['host'], @config['port'], ( @config['ircname'].nil? ? "FBSDBot running on Ruby #{RUBY_VERSION}" : @config['ircname']) )
	
	# global maps
	$commands = {}
	$start_time = Time.now
	$command_count = 0
    $hooks_pubmsg = []
    $hooks_privmsg = []

	IRCEvent.add_callback('nicknameinuse') {|event|	bot.ch_nick( FBSDBot::Helpers::NickObfusicator.run(bot.nick) ) }
	IRCEvent.add_callback('endofmotd') do |event|
  		puts "connected!"
  		load_plugin('corecommands', bot, (File.dirname(__FILE__) + "/../lib/corecommands.rb"))
    	@config['plugins'].each { |plugin| load_plugin(plugin, bot) }
  		@config['channels'].each { |ch| bot.add_channel(ch); puts "Joined channel: #{ch}"}
	end
	$stdout.sync = false
	
	
	IRCEvent.add_callback('privmsg') do |event| 

			if event.message =~ /^!.+/ or event.channel == bot.nick
			  line = event.message.sub(/^!/, '').split
			  unless $commands[line.first].nil?
			    $command_count += 1
			    $commands[line.shift][1].call(event, line.join(' '))
			  end
			end
			
			if event.channel == bot.nick
			  call_hooks(event, :privmsg)
			else
			  call_hooks(event, :pubmsg)
      end
			
			
	end

  bot.connect
