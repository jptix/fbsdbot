# encoding: utf-8
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
      @message = @message[/^\x01ACTION (.+)\x01$/, 1] || discard
    end
  end
  
  
  class CTCPVersionEvent < CTCPEvent
    include Replyable
    
    def initialize(conn, opts = {})
      super
      setup(opts)
    end
    
    def reply(string)
      @worker.send_notice "\x01VERSION #{string}\x01", @user.nick
    end
  end
  
  class CTCPDccEvent < CTCPEvent
    attr_reader :ip, :port
    def initialize(conn, opts = {})
      super
      @to, @message = opts[:params]
      @ip = @port = nil
      if @message =~ /^\x01DCC CHAT CHAT (\d+) (\d+)\x01$/
        @ip = opts[:host] # use $1.to_i.inet_ntoa, when this supports IPv6
        @port = $2.to_i
      else
        discard
      end
    end
  end
  
  class CTCPPingEvent < CTCPEvent; end
  class CTCPClientInfoEvent < CTCPEvent; end
  class CTCPFingerEvent < CTCPEvent; end
  class CTCPTimeEvent < CTCPEvent; end
  class CTCPErrorMessageEvent < CTCPEvent; end
  class CTCPPlayEvent < CTCPEvent; end
  
end
