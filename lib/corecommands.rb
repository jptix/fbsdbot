FBSDBot::Plugin.define("corecommands") {
  author "jp_tix"
  version "0.0.1"
  commands %w{uptime commands}

  def on_msg_uptime(event)
    action.reply "I've been running for #{FBSDBot.seconds_to_s((Time.now - action.worker.start_time).to_i)}"
  end

  def on_msg_commands(event)
    FBSDBot::Plugin.registered_plugins.each do |ident,p|
      event.reply "#{p} available commands: #{p.commands.join(", ")}"
    end
  end

  def on_ctcp_version(event)
    event.reply "running FBSDBot v#{FBSDBot::VERSION} - on Ruby v#{RUBY_VERSION}"
  end
}
