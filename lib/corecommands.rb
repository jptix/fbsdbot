
class Corecommands < PluginBase
  
  def cmd_uptime(event, line)
    reply event, "I've been running for #{seconds_to_s((Time.now - $start_time).to_i)}, during which I have processed #{$command_count} command#{$command_count > 1 ? 's' : ''}."
  end
end