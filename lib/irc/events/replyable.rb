# encoding: utf-8
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

    def reply_to
      who = channel? ? @to : @user.nick
    end

    def reply(string)
      @worker.send_privmsg string.to_s, reply_to
    end
    
  end
end
