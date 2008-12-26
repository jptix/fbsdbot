module FBSDBot
  module Replyable

    attr_reader :to, :message, :nick
    
    def setup(opts)
      @to, @message  = opts[:params]
      @nick          = opts[:nick]
      @user          = opts[:user]
      @host          = opts[:host]
    end

    def reply(string)
      who = self.channel? ? @to : @nick
      @connection.send_message who, string.to_s
    end
    
  end
end