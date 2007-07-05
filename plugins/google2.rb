FBSDBot::Plugin.define "google" do 
	author "Daniel Bond"
	version "0.0.1"

	def on_pubmsg_google(event,line) # becomes a singleton method
		$bot.send_message(event.channel, "google found no match")
	end

end
