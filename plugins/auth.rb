FBSDBot::Plugin.define "AuthHandler" do
	author "Daniel Bond"
	version "0.0.2"

	def on_privmsg_auth(event,line)
		$bot.send_message(event.from, "ok")
	end
end 
