#!/usr/bin/env ruby -KU
	require File.dirname(__FILE__) + '/../lib/boot.rb'
  $stdout.sync = true


  print "Connecting to #{@config['host']}:#{@config['port']}.."
	bot = IRC.new(@config['nick'], @config['host'], @config['port'], "can you say marclar?")
	handler = FBSDBot.new(bot)

	IRCEvent.add_callback('nicknameinuse') {|event|	bot.ch_nick( IRCHelpers::NickObfusicator.run(bot.nick) ) }
	IRCEvent.add_callback('endofmotd') do |event|
	 puts "connected!"
	 @config['channels'].each { |ch| bot.add_channel(ch); puts "Joined channel: #{ch}"}
	end
	$stdout.sync = false
	
	
	IRCEvent.add_callback('privmsg') do |event| 

	     # only handle pubmsgs here ( channel equals my nick if this is a PRIVMSG )
		 unless event.channel == bot.nick
		 	#bot.send_message( event.from, "event: #{event.inspect}") 
		 	#bot.send_message( event.from, "bot: #{bot.inspect}")
		 	if event.message == "!die"
		 	  puts "Reconnecting!"
				bot.send_quit()
			elsif event.message == "!list"
				handler.handle_privmsg(event)
				next # check that we can handle everything through FBSDBot.handle_privmsg ..
				a = User.find(:first, :include => :hosts)
				a.hosts.each do |host|
					bot.send_message(event.channel, host.inspect)
					user_mask = "#{event.from}!#{event.hostmask}"
					matcher = Regexp.new(host.maskexp)
					if matcher.match(user_mask)
						bot.send_message(event.channel, "User #{event.from} (#{event.hostmask}) matched exp: #{host.maskexp}")
					else
						bot.send_message(event.channel, "EXP: #{matcher.inspect} dit not match #{event.from}")
					end
				end
					#if Regexp.new(host.maskexp).match(event.hostmask)
					#	bot.send_message(event.channel, "EXP: #{host.maskexp} matched USER: #{event.username}!#{event.hostmask}")
					#end
			end
		 else
			## PRIVMSG
			## XXX: not working: 
			# FBSDBot.handle_privmsg(event)
     end 
	end

  bot.connect
