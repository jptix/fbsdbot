require "#{File.dirname(__FILE__)}/socket"

module FBSDBot
  module IRC
    class Connection
      attr_reader :socket

      DefaultOptions = {
        :user_name        => 'FBSDBot',
        :real_name        => 'FBSDBot',
        :server_password  => nil
      }
      
      def initialize(nick, server, options = {})
        options = DefaultOptions.merge(options)
        
        @nick   = nick
        @server = server
        
        @user_name = options.delete :user_name
        @real_name = options.delete :real_name
        @server_password = options.delete :server_password
        
        @socket = Socket.new(@server, options)
        @callbacks = Hash.new { |h, k| h[k] = [] }
        @threads = []
      end
      
      def connect
        @threads << Thread.new { read_loop }
        @socket.login(@nick, @user_name, @real_name, @server_password)
        
      end
      
      def join
        @threads.each { |t| t.join }
      end
      
      private
      
      def read_loop
        while line = @socket.read
          parse_line line
        end
        
        @callbacks[:disconnect].each { |cb| cb.call }
      end
      
      def parse_line(line)
        @callbacks[:raw_message].each { |cb| cb.call(line) }
      end
      
      
      
    end
  end
end

if __FILE__ == $0
  conn = FBSDBot::IRC::Connection
end