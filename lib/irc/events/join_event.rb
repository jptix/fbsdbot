module FBSDBot
  class JoinEvent < Event

    attr_reader :nick, :host, :channel
    
    def initialize(conn, opts = {})
      super(conn)
      @nick    = opts[:nick]
      @host    = opts[:host]
      @channel = opts[:params].first
    end
    
  end
end