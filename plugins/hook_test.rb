
class Hook_test < PluginBase
  def hook_pubmsg(event, line)
    if line =~ /^unicode!/
      reply(event, "てすぬむゑげぞずがゐぴ　ずがやふセテネメヤマ")
    end
  end

  def hook_privmsg(event, line)
    reply(event, "that was a private message")
  end

  def hook_join(event, line)
    reply(event, "#{event.from} joined!")
  end

  def hook_part(event, line)
    reply(event, "#{event.from} left!")
  end

  def hook_quit(event, line)
    # no event.channel exists
    puts event.inspect
  end
end
