class User_priv < PluginBase
	def cmd_op(event,line)
		return if line.nil? or line.empty?
		
		User.find(:all, :include => :hosts).each do |user|
			user.hosts.each do |host|
				m = Regexp.new(host.maskexp)
				if m.match("#{event.from}!#{event.hostmask}") 
					if authorize(user,line) # line == password
						op(event.channel,event.from)
					else
						reply(event, "auth failed")
					end
				end
			end
		end
	end

	private 
	def authorize(user,pass)
		return true if user.passwd == Digest::SHA1.hexdigest(pass)
		false
	end
end
