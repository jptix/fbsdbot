FBSDBot::Plugin.define "AuthHandler" do

	author "Daniel Bond"
	version "0.0.2"

	def on_msg_auth(a)
		return unless a.type == :privmsg
		return a.reply "Allready authenticated, use !logout to log out" 	if( a.auth?)

		return a.syntax "<handle> <pass>" 																if( not a.message.match(/^(\S+)\s(\S+)/) )
		handle,pass = $1,$2

		return a.reply "authenticated!"  																	if( a.user.authenticate(a, handle, pass) )
		a.reply "Not authenticated!"
	end

	def on_msg_logout(a)
		return a.reply("Not authenticated anyhowly?") 											unless a.auth?
		a.user.logout(a)
		a.reply "User logged out"
	end

end 
