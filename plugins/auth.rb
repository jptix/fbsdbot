FBSDBot::Plugin.define "AuthHandler" do
	author "Daniel Bond"
	version "0.0.2"

	def on_pubmsg_auth(a)
		if a.auth?
			a.reply("hello world: #{a.message} from #{a.hostmask}")	
		else
		a.reply("not authed")	
		end
	end
end 
