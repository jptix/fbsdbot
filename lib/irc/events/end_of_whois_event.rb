# encoding: utf-8
module FBSDBot
  class EndOfWhoisEvent < Event

    attr_reader :server, :to, :nick, :message

    def initialize(conn, opts = {})
      super(conn)
      @server = opts[:server]
      @to, @nick, @message = opts[:params]
    end
    
  end
end
