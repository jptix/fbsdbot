# encoding: utf-8
module FBSDBot
  class QuitEvent < Event

    attr_reader :user, :message
    
    def initialize(conn, opts = {})
      super(conn)
      @message = opts[:params].first
      @user    = fetch_user(*opts.values_at(:nick, :user, :host))
    end
    
  end
end
