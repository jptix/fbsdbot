module FBSDBot
  class QuitEvent < Event

    attr_reader :nick, :host, :user, :message
    
    def initialize(conn, opts = {})
      super(conn)
      @nick    = opts[:nick]
      @host    = opts[:host]
      @user    = opts[:user]
      @message = opts[:params].first
    end
    
  end
end