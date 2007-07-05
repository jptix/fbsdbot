FBSDBot::Plugin.define "PizzaHighlight" do

	author "Daniel Bond"
	version "0.0.2"


	def on_msg_pizza(a)
	 a.reply("pizza confirmed at #{Time.now}") 
	end

	def on_msg(a)
		if a.message.match(/(.+?) now/)
			m = $1.sub(/^!/)
			a.reply("#{$1} confirmed at #{Time.now}")
		end
	end

end 
