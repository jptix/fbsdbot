# encoding: utf-8
module FBSDBot
  class WhoisServerEvent < Event
    attr_reader :to, :nick, :server, :user_info

    def initialize(conn, opts = {})
      super(conn)
      @to, @nick, @server, @user_info = opts[:params]
    end
  end
end
