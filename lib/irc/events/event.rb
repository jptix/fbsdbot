module FBSDBot
  class Event

    attr_reader :worker

    def initialize(worker)
      @worker = worker
    end
    
    def type
      @type ||= self.class.name.snake_case[/::(.+?)_event/, 1].to_sym
    end
    
    def command?
      @message && @message[0,1] == "!"
    end
    
    def command
      return unless command?
      @message[/!(\w+)/, 1]
    end
    
    def channel?
      @to && IRC::Parser.target_type(@to) == :channel
    end
    
    def inspect
      ivars = instance_variables - %w[@worker]
      str = "#<#{self.class.name}(:#{type}):0x#{self.hash.to_s(16)}"
      ivars.each do |ivar| 
        str << " #{ivar}=#{instance_variable_get(ivar).inspect}"
      end
      
      str << '>'
    end    
  end
end