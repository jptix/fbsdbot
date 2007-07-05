FBSDBot::Plugin.define "PizzaHighlight" do

	author "Daniel Bond"
	version "0.0.2"

	@time = Time.new

	def on_msg_pizza(a)
	 a.reply("pizza confirmed at #{@time}") 
	end

	def on_msg_auth(a)
		return a.reply("Allready authenticated, use !logout to log out") if a.auth?

		a.syntax("<handle> <pass>") if !message.nil or not message.match(/^(\S+)\s(\S+)/)
		a.reply("Not authenticated!")
	end
end 
