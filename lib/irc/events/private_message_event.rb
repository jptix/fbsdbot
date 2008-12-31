module FBSDBot
  class PrivateMessageEvent < Event
    include Replyable
    
    attr_reader :nick
    
    def initialize(connection, opts = {})
      super(connection)
      setup(opts)
      @nick = opts[:nick]
    end
    
  end
end