# encoding: utf-8
module FBSDBot
  class WhoisIdleEvent < Event
    attr_reader :nick, :seconds, :server, :to

    def initialize(conn, opts = {})
      super(conn)
      @server = opts[:server]
      @to, @nick, @seconds = opts[:params]
    end
    
  end
end
