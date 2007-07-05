FBSDBot::Plugin.define "AuthHandler" do
	author "Daniel Bond"
	version "0.0.2"

	def privreply(e,msg)
		$bot.send_message(e.from, msg)
	end

	def on_privmsg_auth(e,line)
		return privreply(e, "You are logged in") if( $auth.is_authenticated?(e) )

		privreply(e, "syntax: <handle> <pass>") unless line.match(/^(\w+)\s(\w+)/)
	end
end 
