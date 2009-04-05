# encoding: utf-8
module FBSDBot
  class TopicEvent < Event

    attr_reader :channel, :topic, :server
    
    def initialize(conn, opts = {})
      super(conn)
      params = opts[:params] 
      params.shift if opts[:command] == '332'

      @channel, @topic = params
      @server = opts[:server]
    end
    
  end
end
