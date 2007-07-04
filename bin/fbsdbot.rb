#!/usr/bin/env ruby -KU
	require File.dirname(__FILE__) + '/../lib/boot.rb'
  $stdout.sync = true

  print "Connecting to #{@config['host']}:#{@config['port']}.."

	bot = IRC.new(@config['nick'], @config['host'], @config['port'], "can you say marclar?")
	
	# global map for commands hash
	$commands = {}
	handler = FBSDBot.new(bot)

	IRCEvent.add_callback('nicknameinuse') {|event|	bot.ch_nick( IRCHelpers::NickObfusicator.run(bot.nick) ) }
	IRCEvent.add_callback('endofmotd') do |event|
  	puts "connected!"
    @config['plugins'].each { |plugin| load_plugin(plugin, bot) }
  	@config['channels'].each { |ch| bot.add_channel(ch); puts "Joined channel: #{ch}"}
	end
	$stdout.sync = false
	
	
	IRCEvent.add_callback('privmsg') do |event| 

	     # only handle pubmsgs here ( channel equals my nick if this is a PRIVMSG )
      puts "event = #{event.inspect}" #    <-- DEBUG
			if event.message =~ /^!(.+)/
			  line = $1.split
			  puts "line = #{line.inspect}" #    <-- DEBUG
			  unless $commands[line.first].nil?
			    puts "line.first = #{line.first.inspect}" #    <-- DEBUG
			    $commands[line.shift][1].call(event, line.join(' '))
			  end
			end
	end

  bot.connect
