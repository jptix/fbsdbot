FBSDBot::Plugin.define(:authentication) do
  version "0.1"

  #
  #  hooks
  # 

  def on_cmd_auth(event)
    case event.message
    when /^!auth identify(.*)$/
      identify(event, $1.strip)
    when /^!auth whoami/
      whoami(event)
    when /^!auth add(.*)$/
      add(event, $1.strip.split(' '))
    when /^!auth set(.*)$/
      set(event, $1.strip)
    when /^!auth list(.*)/
      list(event, $1.strip)
    else
      event.reply "usage: !auth [identify|whoami|add|list|set] <args>"
    end
  end
  
  def on_whois_user(event)
    @whois = event.user
  end
  
  def on_end_of_whois(event)
    return event.worker.send_privmsg("No such user.", @to) unless @whois

    @whois.password = @pass
    @whois.save
    event.worker.send_privmsg("Saved #{@whois}", @to)
    @whois = nil
  end

  # 
  # commands
  # 

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
  
  def list(event, what)
    return event.reply("You can't do that!") unless event.user.bot_master?
    return event.reply("usage: !auth list [all|identified]") unless what =~ /^all|identified$/

    case what
    when "all"
      users = FBSDBot::User.datastore.fetch_all
    when "identified"
      users = FBSDBot::User.datastore.fetch_identified
    else
      Log.warn("unknown arg: #{what.inspect}", self)
    end

    event.reply users.map { |e| e.string }.join(", ")
  end
  
  def set(event, args)
    return event.reply("You can't do that!") unless event.user.bot_master?
    
    unless args =~ /^(\w+) (bot_master|channel_master)/
      return event.reply("usage: !auth set <nick> [bot_master|channel_master]")
    end
    
    nick, flag = $1, $2.to_sym
    user = FBSDBot::User.datastore.fetch_all.find { |e| e.nick == nick }
    unless user
      return event.reply("User not found. Use `!auth add <nick> <pass>`")
    end
    
    user.set_flag(flag)
    user.save
    
    event.reply "User is now a #{flag}."
  end

end