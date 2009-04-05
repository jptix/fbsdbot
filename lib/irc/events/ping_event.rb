# encoding: utf-8
module FBSDBot
  class PingEvent < Event
    
    def initialize(conn, opts = {})
      super(conn)
      @to = opts[:params].first
      pong
    end
    
    def pong
      @worker.send_pong @to
    end
    
  end
end
