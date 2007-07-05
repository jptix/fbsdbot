module FBSDBot
	class Authentication
		def initialize
			@authenticated = {}
		end
		
		def authenticate(event,handle,password)
			u = User.find(:first, :include => [:hosts], :conditions => ['handle = ?',handle])
			return false if u.nil?
			
			#got user, now check pw
			return false unless u.check_password(password)
			
			# XXX: TODO, fix matching of hostmask against user, not just pass			
			@authenticated[event.from.to_sym] = AuthenticatedUser.new(event,u)
			true
		end
		
		def is_authenticated?(event)
			a = @authenticated[event.from.to_sym]
			if a.nil?
				return false
			elsif a.host_changed?(event.hostmask)
				@authenticated.delete(event.from.to_sym)
				return false
			end
			true
		end

		def logout(event)
			a = @authenticated[event.from.to_sym]
			@authenticated.delete(event.from.to_sym) unless a.nil?
			true
		end

		def mapuser(event)
			@authenticated[event.from.to_sym]
		end
		
	end
	
	private
	class AuthenticatedUser
		attr_reader :login_date, :event, :idle_since, :user

		def initialize(event,u)
			@event = event
			@user = u
			@login_date = Time.now
		end

		def host_changed?(host)
			host == @event.hostmask ? false : true
		end
		
	end
end
