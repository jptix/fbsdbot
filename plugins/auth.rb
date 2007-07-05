FBSDBot::Plugin.define "AuthHandler" do

	author "Daniel Bond"
	version "0.0.2"

	def on_privmsg_auth(a)
		return a.reply("allready authenticated")	if a.auth?

		if a.message.match(/^(\S+)\s(\S+)/)
			user,pass = $1,$2 
			return
			if a.auth.authenticate(a,user,pass)
				a.reply "authenticated"
			else
				a.reply "not authenticated"
			end
		else
			a.reply(a.message)
			a.syntax("<user> <pass>")
		end
	end
end 
