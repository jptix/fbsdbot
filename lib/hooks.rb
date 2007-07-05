module FBSDBot
	class Hooks
		def initialize
			@commands = {}
		  @hooks_pubmsg  = []
  		@hooks_privmsg = []
			@hooks_join    = []
			@hooks_part    = []
			@hooks_quit    = []
		end
	end
end
