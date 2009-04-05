# encoding: utf-8
module FBSDBot
  class TopicInfoEvent < Event
    attr_reader :to, :channel, :set_by, :set_at

    def initialize(conn, opts = {})
      super(conn)
      @server = opts[:server]
      @to, @channel, @set_by = opts[:params][0,3]
      
      # TODO: time format might be server-specific
      @set_at = Time.at(opts[:params].last.to_i) 
    end
    
  end
end
