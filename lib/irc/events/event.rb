module FBSDBot
  class Event

    User = Struct.new(:nick, :user, :host)


    def initialize(connection)
      @connection = connection
    end
    
    def type
      @type ||= self.class.name.snake_case[/::(.+?)_event/, 1].to_sym
    end
    
    def inspect
      ivars = instance_variables - %w[@connection]
      str = "#<#{self.class.name}(:#{type}):0x#{self.hash.to_s(16)}"
      ivars.each do |ivar| 
        str << " #{ivar}=#{instance_variable_get(ivar).inspect}"
      end
      
      str << '>'
    end
    
  end
end