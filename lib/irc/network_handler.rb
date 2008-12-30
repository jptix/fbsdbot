require 'lib/irc/em_worker'

module FBSDBot
  include Exceptions
  module IRC
    class NetworkHandler
    
      attr_reader :nick, :port, :realname, :username, :start_time, :retry_in_seconds
    
      def initialize(config)
        @config = config
        @workers = Hash.new
        @port = 6667 ### FIXME! this is irc-server specific
        @nick = config[:nick]
        @realname = config[:realname] || "FBSDBot"
        @username = config[:username] || "fbsd"
        @retry_in_seconds = config[:retry_in_seconds] || 5
        @start_time = Time.now
      end
    
      # Calls create_worker(params ..) for each irc-network in @config (unless it exists)
      def create_workers
        @config[:networks].each {|net| create_worker(*net) }
      end
    
      # Creates a new worker connection instance
      def create_worker(ircnetwork, ircnetwork_specific_data)
        next unless @workers[ircnetwork].nil?
        raise Argument, "IRC-Network not a symbol" unless ircnetwork.is_a?(Symbol)
        raise ArgumentError, "IRC Network Data not a Hash" unless ircnetwork_specific_data.is_a?(Hash)
      
        @workers[ircnetwork] = IRC::EMWorker.connect(self, ircnetwork, ircnetwork_specific_data)
      end
    
      def remove_worker(network)
        # write code for this when needed..
      end
    
      private
    end
  end
end