module FBSDBot
  class NamesEvent < Event
    attr_reader :names
    
    def initialize(conn, opts = {})
      super(conn)
      @names = opts.delete(:params).last.split(' ')
    end
    
  end
end