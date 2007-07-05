FBSDBot::Plugin.define "PizzaHighlight" do

	author "Daniel Bond"
	version "0.0.2"

	@time = Time.new

	def on_pubmsg_pizza(a)
		a.reply("pizza confirmed at #{@time}")	
	end
end 
