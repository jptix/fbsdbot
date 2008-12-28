module FBSDBot
  class NoticeEvent < Event
    include Replyable
    
    def initialize(conn, opts = {})
      super(conn)
      @to, @message = opts[:params]
      
      args = opts.values_at(:nick, :user, :host)
      unless args.include?(nil)
        @user = fetch_user(args)
      end
    end
    
  end
end