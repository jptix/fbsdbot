module FBSDBot
  module Replyable

    attr_reader :to, :message, :nick, :user, :host
    
    def setup(opts)
      @to, @message  = opts[:params]
      @nick          = opts[:nick]
      @user          = opts[:user]
      @host          = opts[:host]
    end

    def reply(string)
      who = self.channel? ? @to : @nick
      @worker.send_privmsg string.to_s, who
    end
    
  end
end