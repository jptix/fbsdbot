FBSDBot::Plugin.define(:authentication) do
  version "0.1"

  def identify(event, pass)
    # if event.channel?
    #   return event.reply("You must identify in private.")
    # end
    return event.reply("usage: !auth identify <password>") if pass.empty?
  
    if event.user.identify(pass)
      event.reply "Ok."
    else
      event.reply "Incorrect password."
    end
  end
  
  def add(event, nick)
    return event.reply("You can't do that!") unless event.user.bot_master?
    return event.reply("usage: !auth add <nick>") if nick.empty?
    event.worker.send_whois(nick) 
  end

  def whoami(event)
    if event.user.identified?
      event.reply "You're #{event.user.nick} (#{event.user})! Woo!"
    else
      event.reply "You're just an object (#{event.user}) to me."
    end
  end

  def on_cmd_auth(event)
    case event.message
    when /^!auth identify(.*)$/
      identify(event, $1.strip)
    when /^!auth whoami/
      whoami(event)
    when /^!auth add(.*)$/
      add(event, $1.strip)
    else
      event.reply "usage: !auth [identify|whoami|add] <args>"
    end
  end
  
end