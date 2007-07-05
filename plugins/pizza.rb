FBSDBot::Plugin.define "PizzaHighlight" do

	author "Daniel Bond"
	version "0.0.2"

	@time = Time.new

	def on_msg_pizza(a)
	 a.reply("pizza confirmed at #{@time}") 
	end

	def on_msg(a)
		a.reply("you said: '#{a.message}'")
	end

end 
