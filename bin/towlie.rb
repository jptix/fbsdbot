#!/usr/bin/env ruby

require File.dirname(__FILE__) + '/../lib/boot.rb'

	bot = IRC.new(@config['nick'], @config['host'], @config['port'], "can you say marclar?")
	IRCEvent.add_callback('nicknameinuse') {|event|
		bot.ch_nick( IRCHelpers::NickObfusicator.run(bot.nick) )
	}
	#IRCEvent.add_callback('endofmotd') { |event| bot.add_channel('#bot-test.no') }
	IRCEvent.add_callback('endofmotd') { |event| bot.add_channel('#FreeBSD.no') }
  #IRCEvent.add_callback('join') {|event| bot.send_message( event.channel, "Hello #{event.from}" ) }
	IRCEvent.add_callback('privmsg') do |event| 

     # only handle pubmsgs here ( channel equals my nick if this is a PRIVMSG )
		 unless event.channel == bot.nick
		 	#bot.send_message( event.from, "event: #{event.inspect}") 
		 	#bot.send_message( event.from, "bot: #{bot.inspect}")
		 	if event.message == "!die"
				bot.send_quit()
			end
		 else
				bot.send_message( event.from, "Why are you talking to me? Go bother someone else please .." )
     end 
	end

  bot.connect
