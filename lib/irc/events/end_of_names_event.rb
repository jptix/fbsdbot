# encoding: utf-8
module FBSDBot
  class EndOfNamesEvent < Event
    
    attr_reader :channel, :server
    
    def initialize(conn, opts = {})
      super(conn)
      @server  = opts[:server]
      @channel = opts[:params][1]
    end
    
  end
end
