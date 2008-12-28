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
  
  def add(event, args)
    return event.reply("You can't do that!") unless event.user.bot_master?
    @nick, @pass = args
    p :args => args, :nick => @nick, :pass => @pass
    if [@nick, @pass].any? { |e| e.nil? }
      return event.reply("usage: !auth add <nick> <pass>") 
    end
    
    @to = event.reply_to
    event.worker.send_whois(@nick)
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
      add(event, $1.strip.split(' '))
    else
      event.reply "usage: !auth [identify|whoami|add] <args>"
    end
  end
  
  def on_whois_user(event)
    @whois = event.user
  end
  
  def on_end_of_whois(event)
    if @whois
      @whois.password = @pass
      @whois.save
      event.worker.send_privmsg("Saved #{@whois}", @to)
      @whois = nil
    else
      event.worker.send_privmsg("No such user.", @to)
    end
  end

end