class User_priv < PluginBase	
	def cmd_auth(event,line)
		l = line.split(' ')
		return reply(event, "Parameters: <handle> <pass>") unless l.size == 2
		
		return reply(event, "You are allready authentiated!") if self.auth.is_authenticated?(event)
		
		if self.auth.authenticate(event, l[0],l[1])
			reply(event, "Ok, you are now authenticated")
		else
			reply(event, "Yes, for the last time, you are a little monkey bwoy!")
		end
		
	end
	
	def cmd_securecall(event,line)
		return reply(event, "You must be authenticated to use this function") unless self.auth.is_authenticated?(event)
		reply(event, "You are special!")
	end

	def cmd_authinfo(event,line)
		return reply(event, "You must be authenticated to use this function") unless self.auth.is_authenticated?(event)
		
		u = self.auth.mapuser(event)
		reply(event, "handle: " + u.user.handle)
		reply(event, "login date: " + u.login_date.to_s)
		u.user.hosts.each do |h|
			reply(event, "host: " + h.maskexp)
		end
	end

	def cmd_logout(event,line)
		self.auth.logout(event)
	end

	def cmd_addhost(event, line)
		return reply(event, "You must be authenticated to use this function") unless self.auth.is_authenticated?(event)
		u = self.auth.mapuser(event)
		unless line.match(/.+!.+@.+/)
			return reply(event, "parameters: <valid hostname>")
		end
			u.user.hosts.create(:maskexp => line)
			reply(event, "added '#{line}' as new hostmask")
	end
end
