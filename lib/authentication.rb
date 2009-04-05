# encoding: utf-8
FBSDBot::Plugin.define(:authentication) do
  author "jptix"
  version "0.1"

  RX_FLAGS = {
    'i' => Regexp::IGNORECASE,
    'x' => Regexp::EXTENDED,
  }

  #
  #  hook
  #
  
  def on_cmd_auth(event)
    case event.message
    when /^!auth whoami/
      whoami(event)
    when /^!auth add(.*)$/
      add(event, $1.strip)
    when /^!auth remove(.*)/
      remove(event, $1.strip)
    when /^!auth set(.*)$/
      set(event, $1.strip)
    when /^!auth list/
      list(event)
    else
      event.reply "usage: !auth [whoami|add|remove|list|set] <args>"
    end
  end

  # ============
  # = commands =
  # ============
  
  def whoami(event)
    event.reply "#{event.user.object_id} :: #{event.user.hostmask}"
  end

  #
  # !auth add <regexp>
  #
  def add(event, pattern)
    return unless check_privilege(event)
    return event.reply("usage: !auth add <regexp>") if pattern.empty?

    begin
      rx = string_to_regexp(pattern)
    rescue
      return event.reply("Invalid regexp: #{pattern.inspect}")
    end

    # need to rethink this
    if FBSDBot::User.datastore.fetch_all.any? { |e| e.hostmask_exp == rx }
      return event.reply("User already added for #{rx.inspect}")
    end
    
    u = FBSDBot::User.new(:hostmask_exp => rx).save
    event.reply "Added user #{u.object_id} for #{rx.inspect}"
  end
  
  #
  # !auth remove <user-id>
  # 
  def remove(event, user_id)
    return unless check_privilege(event)
    return event.reply("usage: !auth remove <user-id>") if user_id !~ /^\d+$/
    
    user = FBSDBot::User.datastore.fetch_all.find { |e| e.object_id == user_id.to_i }
    Log.debug(:found_user => user)
    
    if user.nil?
      event.reply "User not found. Use `!auth list` to show all users."
    elsif user.master?
      Log.warn("Attempt to remove master user by #{event.user.inspect}")
      event.reply "Cannot remove master."
    elsif FBSDBot::User.datastore.remove(:user => user)
      event.reply "User #{user.object_id} removed"
    else
      event.reply "An uknown error occured."
      Log.error("Unknown error while processing #{event.inspect}")
    end
  end

  
  #
  # !auth list
  # 
  def list(event)
    return unless check_privilege(event)
    
    users = FBSDBot::User.datastore.fetch_all
    users.each do |user|
      event.reply("#{user.object_id} :: #{user.hostmask_exp} :: #{user.hostmask}")
    end
  end

  #
  # !auth set
  # 
  def set(event, args)
    return unless check_privilege(event)
    unless args =~ /^(\d+) (admin|user)/
      return event.reply("usage: !auth set <user-id> [admin|user]")
    end

    id, flag = $1, $2
    user = FBSDBot::User.datastore.fetch_all.find { |u| u.object_id == id.to_i }
    if user.nil?
      return event.reply("User not found. Use `!auth add /regexp/`")
    elsif user.master?
      Log.warn("Attempt to change auth level for master by #{event.user.inspect}")
      return event.reply("Cannot change level for master.")
    end

    case flag
    when 'admin'
      user.set_flag(:admin)
    when 'user'
      user.unset_flag(:admin) if user.admin?
    end
    user.save

    event.reply "User #{user.object_id} is now #{flag}"
  end
  
  # ===========
  # = helpers =
  # ===========
  
  def string_to_regexp(pattern)
    raise "Invalid regexp" unless pattern =~ %r{\A/(.*)/([imx]*)\z}
    ptrn, flags = $1, $2.split(//)
    f = flags.inject(0) do |flags, char|
      flags |= RX_FLAGS[char] if RX_FLAGS[char]
      flags
    end

    re = Regexp.new(ptrn, f)
  end
  
  def check_privilege(event)
    result = true
    
    # must be admin
    unless event.user.admin?
      event.reply("You can't do that!") 
      result = false
    end
    
    # must be in private
    if event.channel?
      event.reply("This command must be used in private.") 
      result = false
    end
    
    return result
  end

end # Plugin :authentication
