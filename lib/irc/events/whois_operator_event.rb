# encoding: utf-8
module FBSDBot
  class WhoisOperatorEvent < Event
    attr_reader :to, :nick, :message, :server

    def initialize(conn, opts = {})
      super(conn)
      @server = opts[:server]
      @to, @nick, @message = opts[:params]
    end
    
  end
end
