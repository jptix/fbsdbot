# encoding: utf-8
module FBSDBot
  class WhoisUserEvent < Event
    attr_reader :to, :real_name, :user, :server

    def initialize(conn, opts = {})
      super(conn)
      @server = opts[:server]
      @to, nick, user, host, _, @real_name = opts[:params]
      @user = fetch_user(nick, user, host)
    end
    
  end
end
