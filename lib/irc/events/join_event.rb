module FBSDBot
  class JoinEvent < Event

    attr_reader :nick, :host, :channel
    
    def initialize(conn, opts = {})
      super(conn)
      @nick    = opts.delete(:nick)
      @host    = opts.delete(:host)
      @channel = opts.delete(:params).first
    end
    
  end
end