FBSDBot::Plugin.define "AuthHandler" do

  author "Daniel Bond"
  version "0.0.2"

  def on_msg_auth(a)
    return unless a.type == :privmsg
    return a.reply("Allready authenticated, use !logout to log out")	if( a.auth?)

    return a.syntax("<handle> <pass>")	if( not a.message.match(/^(\S+)\s(.+)/) )

    handle,pass = $1,$2

    return a.reply("authenticated!") if( a.auth.authenticate(a, handle, pass) )
    a.reply("Not authenticated!")
  end

  def on_msg_logout(a)
    return a.reply("Not authenticated anyhowly?")	unless a.auth?
    a.auth.logout(a)
    a.reply("User logged out")
  end

  def on_msg_changepass(a)
    return unless a.type == :privmsg
    return a.reply("Not authed") unless a.auth?
    return a.syntax("!changepass <pass (6-50chars)>") unless a.message.match(/^.*?changepass (.+){6,50}/)
    pp a.auth.mapuser(a).user#.set_password($1)
    a.reply("Password changed!")
  end

  def on_msg_join(a)
    return a.say("to where?") unless a.message.match(/^(\S+)/)
    a.join($1)
  end

  def on_msg_notice(a)
    a.notice("Mr_Bond", a.message)
  end

  def on_msg_op(a)
    return a.reply("Not authed") unless a.auth?
    if a.channel.nil?
      if a.message.match(/^#(\S)/)
        a.op(a.channel)
      else
        return a.reply("No where to op you")
      end
    else
      a.op
    end
  end


end #endplugin
