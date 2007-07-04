#!/usr/bin/env ruby -KU

require File.dirname(__FILE__) + '/../lib/boot.rb'

	bot = IRC.new(@config['nick'], @config['host'], @config['port'], "can you say marclar?")
	FBSDBot.new(bot)
	IRCEvent.add_callback('nicknameinuse') {|event|
		bot.ch_nick( IRCHelpers::NickObfusicator.run(bot.nick) )
	}
	IRCEvent.add_callback('endofmotd') { |event| bot.add_channel('#bot-test.no'); }
	IRCEvent.add_callback('privmsg') do |event| 

	     # only handle pubmsgs here ( channel equals my nick if this is a PRIVMSG )
		 unless event.channel == bot.nick
		 	#bot.send_message( event.from, "event: #{event.inspect}") 
		 	#bot.send_message( event.from, "bot: #{bot.inspect}")
		 	if event.message == "!die"
				bot.send_quit()
			elsif event.message == "!list"
				a = Users.find(:first)
				bot.send_message("#bot-test.no", "First User: #{a.handle}")
			end
		 else
			## PRIVMSG
			## XXX: not working: 
			# FBSDBot.handle_privmsg(event)
     end 
	end

  bot.connect
