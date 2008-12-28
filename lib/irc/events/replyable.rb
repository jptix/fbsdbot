module FBSDBot
  module Replyable

    attr_reader :to, :message, :user
    
    def setup(opts)
      @to, @message  = opts[:params]
      
      args = opts.values_at(:nick, :user, :host)
      unless args.include?(nil)
        @user = fetch_user(*args)
      end
    end

    def reply(string)
      who = channel? ? @to : @user.nick
      @worker.send_privmsg string.to_s, who
    end
    
  end
end