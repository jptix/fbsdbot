# encoding: utf-8
module FBSDBot
  class JoinEvent < Event

    attr_reader :user, :channel
    
    def initialize(conn, opts = {})
      super(conn)
      @user = fetch_user(*opts.values_at(:nick, :user, :host))
      @channel = opts[:params].first
    end
    
  end
end
