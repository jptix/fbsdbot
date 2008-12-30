module FBSDBot
  class PartEvent < Event

    attr_reader :user, :channel, :message
    
    def initialize(conn, opts = {})
      super(conn)
      @channel, @message = opts[:params]
      @user = fetch_user(*opts.values_at(:nick, :user, :host))
    end
    
  end
end