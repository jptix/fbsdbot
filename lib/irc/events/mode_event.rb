module FBSDBot
  class ModeEvent < Event

    attr_reader :user, :channel, :mode, :arguments
    
    def initialize(conn, opts = {})
      super(conn)
      @user    = fetch_user(*opts.values_at(:nick, :user, :host))
      
      # rename @arguments to something else?
      @channel, @mode, @arguments = opts[:params]
    end
    
  end
end