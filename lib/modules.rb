module IRC
	class NickObfusicator
		def NickObfusicator.run( old_nick )
			# find stuff to replace
			new_nick = old_nick
			nick_map = { "a" => "4", "l" => "1", "o" => "0", "e" => "3" } 

			candidates = old_nick.scan(/([aloe])/)
			other_options = ["-","_"]

			i_replacements = 0

			if candidates.size > 0
				candidates = candidates.uniq 
				candidates.each {|c| new_nick = new_nick.to_s.sub("a", nick_map["a"]); i_replacements += 1 }
			end
		
			if i_replacements == 0
				new_nick += other_options[rand((other_options.size) -1)]
				i_replacements += 1
			end
			new_nick
		end
	end
end

