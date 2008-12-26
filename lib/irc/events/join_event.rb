module FBSDBot
  class JoinEvent < Event
    
    def initialize(conn, opts = {})
      super(conn)
      p :joined => opts
    end
    
  end
end