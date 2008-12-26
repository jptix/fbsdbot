module FBSDBot
  class EndOfMotdEvent < Event
    
    def initialize(conn, opts = {})
      super(conn)
      p :end_of_motd => opts
    end
    
  end
end