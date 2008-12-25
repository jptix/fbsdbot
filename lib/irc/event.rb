module FBSDBot
  class Event
    attr_accessor :type, :message, :from, :hostmask, :channel, :to, 
                  :sender, :params
                  
    User = Struct.new(:nick, :hostmask)
    
    TypeTranslation = {
      :end_of_motd     => 'endofmotd',
      :ping            => 'ping',
      :private_message => 'privmsg'
    }
    
    def initialize(type = nil, opts = {})
      @type       = type
      @message    = opts.delete(:message)
      @from       = opts.delete(:from)
      self.sender = opts.delete(:sender) if opts.has_key?(:sender)
      self.params = opts.delete(:params) if opts.has_key?(:params)
    end

    def params=(input)
      if input.is_a? Hash
        @params  = input
        @message = input[:message]
        @channel = input[:to]
      else
        @params = input
      end
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
    
  end
end