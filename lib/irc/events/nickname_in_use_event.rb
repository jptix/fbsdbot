# encoding: utf-8
module FBSDBot
  class NicknameInUseEvent < Event
    attr_reader :nick
    
    def initialize(conn, opts = {})
      super(conn)
      @nick = opts[:params][1]
    end
    
  end

end
