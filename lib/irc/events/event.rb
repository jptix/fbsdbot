module FBSDBot
  
  class Event

    attr_reader :worker

    def self.type
      return @type if defined?(@type)
      
      if ev = name.snake_case[/::(.+?)_event/, 1]
        @type = ev.to_sym
      else
        @type = name.snake_case.to_sym
      end
    end
    
    def initialize(worker)
      @worker = worker
    end
    
    def type
      self.class.type
    end
    
    def command?
      defined?(@message) && @message[0,1] == "!"
    end
    
    def command
      return unless command?
      @message[/!(\w+)/, 1]
    end
    
    def channel?
      @to && IRC::Parser.target_type(@to) == :channel
    end
    
    def inspect
      ivars = (instance_variables - %w[@worker]).sort
      str = "#<#{self.class.name}(:#{type}):0x#{self.hash.to_s(16)}"
      ivars.each do |ivar| 
        str << " #{ivar}=#{instance_variable_get(ivar).inspect}"
      end
      
      str << '>'
    end
    
    private
    
    def fetch_user(nick, user, host)
      string = "#{nick}!#{user}@#{host}"
      
      if u = User.datastore.fetch(:hostmask => string)
        u.update(nick, user, host)
        return u
      else
       User.cache[string]
     end
    end
    
  end # class User
end # module FBSDBot