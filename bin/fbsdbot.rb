#!/usr/bin/env ruby -KU
	require File.dirname(__FILE__) + '/../lib/boot.rb'
  $stdout.sync = true

  print "Connecting to #{@config['host']}:#{@config['port']}.."

	bot = IRC.new(@config['nick'], @config['host'], @config['port'], "can you say marclar?")
	
	# global maps
	$commands = {}
	$start_time = Time.now
	$command_count = 0
	handler = FBSDBot.new(bot)

	IRCEvent.add_callback('nicknameinuse') {|event|	bot.ch_nick( IRCHelpers::NickObfusicator.run(bot.nick) ) }
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
	end

  bot.connect
