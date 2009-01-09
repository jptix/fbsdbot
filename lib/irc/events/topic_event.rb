module FBSDBot
  class TopicEvent < Event

    attr_reader :to, :channel, :topic, :server
    
    def initialize(conn, opts = {})
      super(conn)
      @to, @channel, @topic = opts[:params]
      @server = opts[:server]
    end
    
  end
end