#!/usr/bin/env ruby

require File.dirname(__FILE__) + '/../lib/boot.rb'

	puts @config.inspect

	bot = IRC.new(@config['nick'], @config['host'], @config['port'], "can you say marclar?")
	IRCEvent.add_callback('nicknameinuse') {|event|
		bot.ch_nick "x7vf3k"
	}
	IRCEvent.add_callback('endofmotd') { |event| bot.add_channel('#bot-test.no') }
  #IRCEvent.add_callback('join') {|event| bot.send_message( event.channel, "Hello #{event.from}" ) }
	IRCEvent.add_callback('privmsg') do |event| 

     # only handle pubmsgs here ( channel equals my nick if this is a PRIVMSG )
		 unless event.channel == bot.nick
		 	#bot.send_message( event.from, "event: #{event.inspect}") 
		 	#bot.send_message( event.from, "bot: #{bot.inspect}")
			else
				bot.send_message( event.from, "Why are you talking to me? Go bother someone else please .." )
     end 
	end

  bot.connect

# #<IRCEvent:0xb799aedc @hostmask="danb@noc.nsn.no", @from="Mr_Bond", @message="h", @channel="#bot-test.no", @event_type="privmsg", @user=#<IRCUser:0xb799ad4c @username="Mr_Bond">, @stats=["Mr_Bond", "danb@noc.nsn.no", "PRIVMSG", "#bot-test.no"]>
#<IRCEvent:0xb799a98c @hostmask="danb@noc.nsn.no", @from="Mr_Bond", @message="bitch", @channel="Towli3", @event_type="privmsg", @user=#<IRCUser:0xb799ad4c @username="Mr_Bond">, @stats=["Mr_Bond", "danb@noc.nsn.no", "PRIVMSG", "Towli3"]>
