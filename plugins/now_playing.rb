class Now_playing < PluginBase
     
   def cmd_np(event, line)
			at = "/usr/bin/audtool"
			song = `#{at} --current-song`	
			bitrate =  `#{at} --current-song-bitrate-kbps`
			answer = "Mr_Bond is playing: #{song} [#{bitrate}Kb/s]"
			unless event.from == "Mr_Bond"
				answer = "#{event.from}'s music is to gay to mention here!"
			end
			reply(event,answer)
	 end
   
end
