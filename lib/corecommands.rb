# encoding: utf-8
FBSDBot::Plugin.define("corecommands") {
  author "jp_tix"
  version "0.0.1"

  def on_cmd_uptime(event)
    event.reply "I've been running for #{ seconds_to_s((Time.now - event.worker.start_time).to_i) }"
  end

  def on_cmd_commands(event)
    FBSDBot::Plugin.registered_plugins.each do |name,plugin|
      next if plugin.commands.empty?
      event.reply "#{plugin} available commands: #{plugin.commands.join(", ")}"
    end
  end

  def on_ctcp_version(event)
    event.reply "running FBSDBot v#{FBSDBot::VERSION} - on Ruby v#{RUBY_VERSION}"
  end
  
}
