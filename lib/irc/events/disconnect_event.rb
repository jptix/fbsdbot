module FBSDBot
  class DisconnectEvent < Event
    
    def initialize(conn, opts = {})
      super(conn)
      p :disconnected => conn
    end
    
  end
end