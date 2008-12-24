require "#{File.dirname(__FILE__)}/socket"
require "#{File.dirname(__FILE__)}/parser"
require "#{File.dirname(__FILE__)}/event"

module FBSDBot
  module IRC
    class Connection
      attr_reader :socket, :nick, :server
      attr_accessor :delegate

      DefaultOptions = {
        :user_name        => 'FBSDBot',
        :real_name        => 'FBSDBot',
        :server_password  => nil
      }
      
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
        @socket.log_out = $stderr if $DEBUG
        
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

      def join_channel(channel)
        channel = "\##{channel}" unless channel[/^#/]
        @socket.send_join(channel)
      end
      
      def send_message(recipient, message)
        @socket.send_privmsg(message, recipient)
      end
      
      def send_notice(recipient, notice)
        @socket.send_notice(notice, recipient)
      end
      
      private
      
      def execute_callbacks(event)
        p :event => event
        cbs = @callbacks[type = event.type]
        missing_callback(type, event) if cbs.empty?
        cbs.each { |cb| cb.call(event) }
        
        if @delegate
          @delegate.send("on_#{event.type}", self, event)
        end
      end
      
      def read_loop
        while line = @socket.read
          parse_line line
        end
        
        e = Event.new(:disconnect)
        e.message = "connection closed"
        
        execute_callbacks(e)
      end
      
      def parse_line(line)
        @callbacks[:raw_message].each { |cb| cb.call(line) }
        e = @parser.parse_line(line)
        if e.is_a?(Event)
          execute_callbacks(e)
        else
          puts "no event for #{line}"
        end
      end
      
      def missing_callback(event_type, event)
        case event_type
        when :ping
          @socket.send_pong(event.message)
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