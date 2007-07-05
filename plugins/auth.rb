FBSDBot::Plugin.define "AuthHandler" do
	author "Daniel Bond"
	version "0.0.2"

	def on_pubmsg_auth(a)
		a.reply("hello world: #{a.message} from #{a.hostmask}")	
	end
end 
