module FBSDBot
  class NoticeEvent < Event
    include Replyable
    
    def initialize(conn, opts = {})
      super(conn)
      setup(opts)
    end
    
  end
end