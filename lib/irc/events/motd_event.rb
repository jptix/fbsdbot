module FBSDBot
  class MotdEvent < Event
    
    attr_reader :server
    
    def initialize(conn, opts = {})
      super(conn)
      @server = opts[:server]
    end
    
  end
end