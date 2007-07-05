FBSDBot::Plugin.define "google" do 
	author "Daniel Bond"
	version "0.0.1"

	def on_pubmsg_google(event,line) # becomes a singleton method
		$bot.irc.send_message(event.channel, "google found no match")
	end

	def on_pubmsg_auth(event, line)
		return $bot.irc.send_message(event.channel, "Go away!") unless $bot.auth.is_authenticated?(event)
	end

end
