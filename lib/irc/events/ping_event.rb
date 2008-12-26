module FBSDBot
  class PingEvent < Event
    
    def initialize(conn, opts = {})
      super(conn)
      @to = opts[:params].first
      pong
    end
    
    def pong
      @connection.send_pong @to
    end
    
  end
end