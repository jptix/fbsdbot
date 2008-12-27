require "#{File.dirname(__FILE__)}/socket"

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
        @event_producer = EventProducer.new(self)
        
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
      
      def send_pong(who)
        @socket.send_pong who
      end
      
      def change_nick(new_nick)
        @socket.send_nick new_nick
      end
      
      private
      
      def execute_callbacks(event)
        Log.debug :event => event
        cbs = @callbacks[type = event.type]
        cbs.each { |cb| cb.call(event) }
        
        if @delegate
          @delegate.send("on_#{event.type}", self, event)
        end
      end
      
      def read_loop
        while line = @socket.read
          parse_line line
        end
        
        execute_callbacks @event_producer.disconnect_event
      end
      
      def parse_line(line)
        @callbacks[:raw_message].each { |callback| callback.call(line) }
        e = @event_producer.parse_line(line)
        if e.is_a?(Event)
          execute_callbacks(e)
        else
          Log.warn "no event for #{line}"
        end
      end
      
    end # Connection
  end # IRC
end # FBSDBot
