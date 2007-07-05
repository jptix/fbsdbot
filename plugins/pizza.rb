FBSDBot::Plugin.define "PizzaHighlight" do

	author "Daniel Bond"
	version "0.0.2"


	def on_msg_pizza(a)
	if a.message.match(/^pizza now/)
	 a.reply("pizza confirmed at #{Time.now}")
	else
	 a.syntax("<when>") 
	end
	end

	def on_msg(a)
		if a.message.match(/(.+?) now/)
			a.reply("#{$1.sub(/^!/,'')} confirmed at #{Time.now}")
		end
	end

end 
