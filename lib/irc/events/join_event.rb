module FBSDBot
  class JoinEvent < Event

    attr_reader :user, :channel
    
    def initialize(conn, opts = {})
      super(conn)
      
      args = opts.values_at(:nick, :user, :host)
      unless args.include?(nil)
        @user = fetch_user(*args)
      end
      @channel = opts[:params].first
    end
    
  end
end