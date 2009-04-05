# encoding: utf-8
module FBSDBot
  class WhoisChannelsEvent < Event
    attr_reader :server, :to, :nick, :channel_string

    def initialize(conn, opts = {})
      super(conn)
      @server = opts[:server]
      @to, @nick, @channel_string = opts[:params]
    end
    
  end
end
