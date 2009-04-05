# encoding: utf-8
module FBSDBot
  class KickEvent < Event

    attr_reader :user, :message, :channel, :nick
    
    def initialize(conn, opts = {})
      super(conn)
      @channel, @nick, @message = opts[:params]
      @user    = fetch_user(*opts.values_at(:nick, :user, :host))
    end
    
  end
end
