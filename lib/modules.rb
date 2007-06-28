module IRCHelpers
	class NickObfusicator
		def NickObfusicator.run( old_nick )
			# replace old_nick
			old_nick[rand(old_nick.size - 1)] = (rand(122-97) + 97).chr
			return old_nick
		end
	end
end

IRCHelpers::NickObfusicator.run("Mr_Bond")
