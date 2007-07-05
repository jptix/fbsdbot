FBSDBot::Plugin.define "PizzaHighlight" do

	author "Daniel Bond"
	version "0.0.3"


	def on_msg_pizza(a)
	if a.message.match(/^now/)
	 a.reply("pizza confirmed at #{Time.now}")
	else
	 a.reply(a.message.inspect)
	 a.syntax("<when>") 
	end
	end

	def on_msg(a)
		if a.message.match(/(.+?) now/)
			a.reply("#{$1.sub(/^!/,'')} confirmed at #{Time.now}")
		end
	end

	def on_msg_reload(a)
			a.reply("reloading")
			sefl.caller.exit
	end

end 
