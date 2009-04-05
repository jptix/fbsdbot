# encoding: utf-8
module FBSDBot
  class NoMotdEvent < Event
    
    attr_reader :server
    
    def initialize(conn, opts = {})
      super(conn)
      @server = opts[:server]
    end
    
  end
end
