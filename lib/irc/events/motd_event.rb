# encoding: utf-8
module FBSDBot
  class MotdEvent < Event
    
    attr_reader :server, :to, :message
    
    def initialize(conn, opts = {})
      super(conn)
      @server       = opts[:server]
      @to, @message = opts[:params]
    end
    
  end
end
