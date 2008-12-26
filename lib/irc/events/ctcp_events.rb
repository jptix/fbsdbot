module FBSDBot
  class CTCPEvent < Event
    
    def initialize(conn, opts = {})
      super(conn)
    end
    
  end

  class CTCPActionEvent < CTCPEvent
    attr_reader :to, :message
    
    def initialize(conn, opts = {})
      super
      @to, @message = opts[:params]
      @message = @message[/\x01ACTION (.+)\x01/, 1]
    end
  end
  
  
  class CTCPVersionEvent < CTCPEvent
    include Replyable
    
    def initialize(conn, opts = {})
      super
      setup(opts)
    end
    
    def reply(string)
      @connection.send_notice @nick, "\x01VERSION #{string}\x01"
    end
  end
  
  class CTCPPingEvent < CTCPEvent; end
  class CTCPClientInfoEvent < CTCPEvent; end
  class CTCPFingerEvent < CTCPEvent; end
  class CTCPTimeEvent < CTCPEvent; end
  class CTCPDccEvent < CTCPEvent; end
  class CTCPErrorMessageEvent < CTCPEvent; end
  class CTCPPlayEvent < CTCPEvent; end
  
end