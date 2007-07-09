FBSDBot::Plugin.define("corecommands") {
   author "jp_tix"
   version "0.0.1"
  
  def on_msg_uptime(action)
    action.reply "I've been running for #{FBSDBot.seconds_to_s((Time.now - $bot.start_time).to_i)}, during which I have processed #{$bot.command_count} command#{$bot.command_count > 1 ? 's' : ''}."
  end

  # def on_msg_commands(action)
  #   action.reply "My commands are: " + FBSDBot::Plugin.registered_plugins.keys.join(", ")
  # end
	def on_ctcp_version(action)
		action.reply "running FBSDBot v#{FBSDBot::VERSION} - on Ruby v#{RUBY_VERSION}"
	end
}
