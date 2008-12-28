module FBSDBot
  module Replyable

    attr_reader :to, :message, :user
    
    def setup(opts)
      @to, @message  = opts[:params]
      @user          = fetch_user(*opts.values_at(:nick, :user, :host))
    end

    def reply(string)
      who = self.channel? ? @to : @user.nick
      @worker.send_privmsg string.to_s, who
    end
    
  end
end