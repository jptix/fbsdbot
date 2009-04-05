# encoding: utf-8
module FBSDBot
  class ModeEvent < Event

    attr_reader :user, :channel, :mode, :arguments, :server
    
    def initialize(conn, opts = {})
      super(conn)
      args = opts.values_at(:nick, :user, :host)
      if args.include?(nil)
        @server = opts[:server]
      else
        @user = fetch_user(*args)
      end

      
      # rename @arguments to something else?
      @channel, @mode, @arguments = opts[:params]
    end
    
  end
end
