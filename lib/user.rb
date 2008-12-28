module FBSDBot
  class User
    attr_reader :nick, :user, :host
    
    def initialize(nick, user, host)
      @nick, @user, @host = nick, user, host
    end
    
  end
end