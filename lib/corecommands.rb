
class Corecommands < PluginBase
  
  def cmd_uptime(event, line)
    reply event, "I've been running for #{seconds_to_s((Time.now - $bot.start_time).to_i)}, during which I have processed #{$bot.command_count} command#{$bot.command_count > 1 ? 's' : ''}."
  end
  
  def cmd_commands(event, line)
    reply event, "My commands are: " + $commands.keys.join(", ")
  end
end