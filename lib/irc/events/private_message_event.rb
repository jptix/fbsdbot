# encoding: utf-8
module FBSDBot
  class PrivateMessageEvent < Event
    include Replyable
    
    def initialize(connection, opts = {})
      super(connection)
      setup(opts)
    end
    
  end
end
