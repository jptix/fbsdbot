module FBSDBot
  class Event
    attr_accessor :type, :message, :from, :hostmask, :channel, :to
    User = Struct.new(:nick, :hostmask)
    
    TypeTranslation = {
      :end_of_motd     => 'endofmotd',
      :ping            => 'ping',
      :private_message => 'privmsg'
    }
    
    def initialize(type = nil, opts = {})
      @type = type
      @message = opts.delete(:message)
      @from = opts.delete(:from)
    end
    
    def user=(user)
      @user     = User === user ? user : parse_user(user)
      @from     = @user.nick
      @hostmask = @user.hostmask
    end
    
    def to=(to)
      @to = @channel = to[/:?(.+)/, 1].strip if to
    end
    
    def add_error(msg)
      @event_type = :error
      @message = msg
    end
    
    # translate our new event types to the old format if possible
    def event_type
      TypeTranslation[@type] || @type.to_s
    end
    
    private
    
    def parse_user(user_string)
      if user_string =~ /:(.+?)!(.+?)/
        return User.new($1, $2)
      else 
        puts "could not parse user: #{user_string}"
        User.new(user_string, '')
      end
    end
    
  end
end