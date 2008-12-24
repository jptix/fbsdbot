module FBSDBot
  class Event
    attr_accessor :type, :message, :from, :hostmask, :channel, :to, :sender
                  :params
                  
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

    def params=(hash)
      @params = hash
      @message = hash[:message]
      @channel = hash[:to]
    end
    
    def sender=(hash)
      @sender   = hash
      @from     = hash[:nick]
      @hostmask = "#{hash[:user]}@#{hash[:host]}"
    end
    
    
    # translate our new event types to the old format if possible
    def event_type
      TypeTranslation[@type] || @type.to_s
    end
    
    private
    
    
  end
end