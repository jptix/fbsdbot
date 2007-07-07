FBSDBot::Plugin.define "now_playing" {
	 author "Daniel Bond <gitbits@danielbond.org>"
	 version "0.0.1"
     
   def on_msg_np(action)
			at = "/usr/bin/audtool"
			song = `#{at} --current-song`	
			bitrate =  `#{at} --current-song-bitrate-kbps`
			answer = "is playing: #{song} [#{bitrate}Kb/s]"
			unless event.from == "Mr_Bond"
				answer = "#{event.from}'s music is to gay to mention here!"
			end
			reply(answer)
	 end
   

}

