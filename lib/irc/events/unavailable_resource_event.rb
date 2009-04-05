# encoding: utf-8
module FBSDBot
  class UnavailableResourceEvent < Event

    attr_reader :to, :resource, :message, :server
    
    def initialize(conn, opts = {})
      super(conn)
      @to, @resource, @message = opts[:params]
      @server = opts[:server]
    end
    
  end
end
