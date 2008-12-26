module FBSDBot
  class CTCPEvent < Event
    
    def initialize(conn, opts = {})
      super(conn)
    end
    
  end

    class CTCPVersionEvent < CTCPEvent; end
    class CTCPPingEvent < CTCPEvent; end
    class CTCPClientInfoEvent < CTCPEvent; end
    class CTCPActionEvent < CTCPEvent; end
    class CTCPFingerEvent < CTCPEvent; end
    class CTCPTimeEvent < CTCPEvent; end
    class CTCPDccEvent < CTCPEvent; end
    class CTCPErrorMessageEvent < CTCPEvent; end
    class CTCPPlayEvent < CTCPEvent; end
  
end