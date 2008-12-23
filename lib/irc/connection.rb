require "#{File.dirname(__FILE__)}/socket"
require "#{File.dirname(__FILE__)}/parser"

module FBSDBot
  module IRC
    class Connection
      attr_reader :socket
      attr_accessor :delegate

      DefaultOptions = {
        :user_name        => 'FBSDBot',
        :real_name        => 'FBSDBot',
        :server_password  => nil
      }
      
      # a list of callbacks
      Callbacks = [ :disconnect, :raw_message, :private_message  ]
      
      def initialize(nick, server, options = {})
        options = DefaultOptions.merge(options)
        @parser = Parser.new
        
        @nick   = nick
        @server = server
        @log    = $stdout # for now
        
        @user_name = options.delete :user_name
        @real_name = options.delete :real_name
        @server_password = options.delete :server_password
        
        @socket = Socket.new(@server, options)
        
        @callbacks = Hash.new { |h, k| h[k] = [] }
        @threads = []
        
        @delegate = nil
      end

      def connect
        @socket.login(@nick, @user_name, @real_name, @server_password)
        @threads << Thread.new { read_loop }
      end
      
      def join
        @threads.each { |t| t.join }
      end
      
      def add_callback(symbol, &block)
        @callbacks[symbol] << block
      end

      # perhaps remove callback code entirely and base everything on delegates?
      #
      # # adding a delegate currently removes all previously added callbacks,
      # # so you're forced to choose either a delegate or a callback approach
      # #  
      # def delegate=(obj)
      #   @callbacks.clear
      #   
      #   Callbacks.each do |sym|
      #     meth = "on_#{sym}"
      #     
      #     if obj.respond_to?(meth)
      #       @callbacks[sym] << lambda { |*args| @delegate.send(meth, self, *args)}
      #     end
      #   end
      #   
      #   @callbacks.keys
      # end
      
      private
      
      def read_loop
        while line = @socket.read
          parse_line line
        end
        
        @callbacks[:disconnect].each { |cb| cb.call }
      end
      
      def parse_line(line)
        @callbacks[:raw_message].each { |cb| cb.call(line) }
        sym, *args = @parser.parse_line(line)
        
        p :got => sym
        if cbs = @callbacks[sym]
          cbs.each { |cb| cb.call(*args) }
        end
      end
      
      
      
    end
  end
end

if __FILE__ == $0
  conn = FBSDBot::IRC::Connection.new('utf8v2', 'irc.freenode.net')
  conn.add_callback(:raw_message)     { |line| p line }
  conn.add_callback(:private_message) { |from, to, msg| p :from => from, :to => to, :msg => msg }
  conn.connect
  conn.join
end