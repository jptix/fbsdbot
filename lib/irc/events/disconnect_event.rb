module FBSDBot
  class DisconnectEvent < Event
    
    def initialize(conn, opts = {})
      super(conn)
      warn :disconnected => conn
    end
    
  end
end