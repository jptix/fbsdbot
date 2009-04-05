# encoding: utf-8
module FBSDBot
  class NickEvent < Event

    attr_reader :user, :nick
    
    def initialize(conn, opts = {})
      super(conn)
      
      args = opts.values_at(:nick, :user, :host)
      unless args.include?(nil)
        @user = fetch_user(*args)
      end
      @nick = opts[:params].first
    end
    
  end
end
