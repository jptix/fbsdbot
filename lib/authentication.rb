FBSDBot::Plugin.define(:authentication) do
  version "0.1"

  RX_FLAGS = {
    'i' => Regexp::IGNORECASE,
    'x' => Regexp::EXTENDED,
  }
  #
  #  hooks
  #

  def on_cmd_auth(event)
    case event.message
    when /^!auth whoami/
      whoami(event)
    when /^!auth add(.*)$/
      add(event, $1.strip)
    when /^!auth set(.*)$/
      set(event, $1.strip)
    when /^!auth list(.*)/
      list(event, $1.strip)
    else
      event.reply "usage: !auth [whoami|add|list|set] <args>"
    end
  end

  #
  # commands
  #

  def add(event, pattern)
    return event.reply("You can't do that!") unless event.user.admin?
    if pattern.nil?
      return event.reply("usage: !auth add <regexp>")
    end

    return event.reply("Invalid regexp") unless pattern =~ %r{\A/(.*)/([imx]*)\z}

    begin
      ptrn, flags = $1, $2.split(//)
      f = flags.inject(0) do |flags, char|
        flags |= RX_FLAGS[char] if RX_FLAGS[char]
        flags
      end

      re = Regexp.new(ptrn, f)
    rescue
      event.reply "Invalid regexp #{pattern.inspect}"
    end

    u = FBSDBot::User.new(nil, nil, nil)
    u.hostmask_exp = re
    u.save

    event.reply "Added user for #{re.inspect}"
  end

  def whoami(event)
    event.reply "#{event.user} :: #{event.user.hostmask} :: #{event.user.hostmask_exp}"
  end

  def list(event, what)
    return event.reply("You can't do that!") unless event.user.admin?

    users = FBSDBot::User.datastore.fetch_all
    event.reply users.map { |e| e.hostmask }.join(", ")
  end

  def set(event, args)
    return event.reply("You can't do that!") unless event.user.admin?

    unless args =~ /^(\w+) (admin|user)/
      return event.reply("usage: !auth set <nick> [admin|user]")
    end

    nick, flag = $1, $2
    user = FBSDBot::User.datastore.fetch_all.find { |e| e.nick == nick }
    unless user
      return event.reply("User not found. Use `!auth add <nick> /regexp/`")
    end

    case flag
    when 'admin'
      user.set_flag(:admin)
    when 'user'
      user.unset_flag(:admin) if user.admin?
    end
    user.save

    event.reply "User is now #{flag}"
  end

end
