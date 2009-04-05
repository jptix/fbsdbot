# encoding: utf-8
module FBSDBot
  class PartEvent < Event

    attr_reader :user, :channel, :message
    
    def initialize(conn, opts = {})
      super(conn)
      @channel = opts[:params].first
      @message = opts[:params].last.to_s # will be nil if no message was given
      @user = fetch_user(*opts.values_at(:nick, :user, :host))
    end
    
  end
end
