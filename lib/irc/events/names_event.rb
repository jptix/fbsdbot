module FBSDBot
  class NamesEvent < Event
    
    def initialize(conn, opts = {})
      super(conn)
      @names = opts.delete(:params).last.split(' ')
    end
    
  end
end