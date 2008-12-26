module FBSDBot
  class PartEvent < Event

    attr_reader :nick, :host, :user, :channel, :message
    
    def initialize(conn, opts = {})
      super(conn)
      @channel, @message = opts[:params]
      @nick = opts[:nick]
      @host = opts[:host]
      @user = opts[:user]
    end
    
  end
end