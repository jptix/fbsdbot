module FBSDBot
  class PrivateMessageEvent < Event
    attr_reader :to, :message, :nick
    
    
    def initialize(connection, opts = {})
      super(connection)
      @to, @message  = opts.delete(:params)
      @nick          = opts.delete(:nick)
      @user          = opts.delete(:user)
      @host          = opts.delete(:host)
    end
    
    def channel?
      @to[0,1] == "#"
    end
    
    def command?
      @message[0,1] == "!"
    end
    
    def reply(string)
      @connection.send_message @nick, string.to_s
    end
    
  end
end