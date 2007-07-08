FBSDBot::Plugin.define "PizzaHighlight" do

	author "Daniel Bond"
	version "0.0.3"

	class Test < Time

	end

	@timings = {}
	
	def on_msg(a)
		if a.message.match(/(.+?) now/)
			t = Test.now
			@timings[$1] = t
			a.reply("#{$1.sub(/^!/,'')} confirmed at #{t}")
		end

		if a.message.match(/(.+?) when\?/)
			t = @timings[$1]
			a.reply("#{$1} was confirmed #{FBSDBot::seconds_to_s(Time.now.to_i - t.to_i)} ago") unless t.nil?
		end
	end
end 
