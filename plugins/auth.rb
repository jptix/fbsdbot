FBSDBot::Plugin.define "AuthHandler" do

	author "Daniel Bond"
	version "0.0.2"

	def on_msg_auth(a)
		return unless a.type == :privmsg
		return a.reply "Allready authenticated, use !logout to log out"	if( a.auth?)

		return a.syntax "<handle> <pass>"	if( not a.message.match(/^.*auth (\S+)\s(.+)/) )

		handle,pass = $1,$2

		return a.reply "authenticated!" if( a.auth.authenticate(a, handle, pass) )
		a.reply "Not authenticated!"
	end

	def on_msg_logout(a)
		return a.reply("Not authenticated anyhowly?")	unless a.auth?
		a.auth.logout(a)
		a.reply "User logged out"
	end

	def on_msg_changepass(a)
		return unless a.type == :privmsg
		return a.reply("Not authed") unless a.auth?
		return a.syntax("!changepass <pass (6-50chars)>") unless a.message.match(/^.*?changepass (.+){6,50}/) 
		pp a.auth.mapuser(a).user#.set_password($1)
		a.reply("Password changed!")
	end

end 
