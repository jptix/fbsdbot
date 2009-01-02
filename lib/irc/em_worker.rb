require 'lib/irc/commands'
require 'lib/irc/constants'

module FBSDBot
  module IRC
    class EMWorker < EventMachine::Connection
      attr_accessor :handler
      attr_reader :start_time
      include EventMachine::Deferrable
      include Commands
      include Constants

      def self.connect(handler, network, instance_data)
        server = instance_data[:servers].pick
        begin
          EventMachine::connect( server, handler.port, self) do |instance|
            instance.instance_eval {
              @handler = handler
              @network = network
              @server = server
              @instance_data = instance_data
              @channels = instance_data[:channels] || Array.new
              @event_producer = EventProducer.new(self)
              Log.info("Connecting to server #{server}", self)
            }
          end
        rescue RuntimeError => e
          Log.warn "Could not connect to #{network}, #{server}:#{handler.port} (#{e.class} => #{e}) - sleeping #{handler.retry_in_seconds} seconds", self
          EventMachine::add_timer(handler.retry_in_seconds) { connect(handler, network, instance_data) }
        end
      end
      
      def to_s
        "#<EMWorker:#%x #{@network} [c#{connected?.tiny_s}:r#{reconnect?.tiny_s}]>" % object_id
      end
      
      def post_init
        @start_time = Time.now
        @buffer = ""
        @connected = false
        @shutdown = false
      end
      
      def connection_completed
        @connected = true
        Log.info "Connected.", self

        login
      end
      
      def receive_data(data)
        lines = 0
        data.each_line(EOL) do |line|
          next if line == EOL
          if line =~ EXP_EOL 
            lines += 1 
            produce_event(line) 
          else
            @buffer << line
          end
        end
        
        lines
      end

      def produce_event(line)
        message = @buffer.empty? ? line : @buffer + line
        @buffer = "" # important, reset buffer!

        handle_event(@event_producer.parse_line(message))
      end
      
      def handle_event(event)
        Log.debug(:handle_event => event)
        return if event.nil?
        raise TypeError, "Not passed an Event.class" unless event.is_a?(Event)

        return if event.discard?

        case(event)
        when EndOfMotdEvent
          Log.info "Joining channels: #{@channels.join(", ")}", self
          send_join(*@channels)
        when NicknameInUseEvent
          send_nick Helpers.obfuscate_nick(@handler.nick)
        else
          ## CREATE cases above for events we don't want plugins to be able to handle
          return if event.stop?
          Plugin.run_event event
        end
      end
     
      def unbind
        @connected = false
        Log.info("Disconnected from #{@server}", self)
        next_server = @instance_data[:servers].pick
        Log.info("Re-connecting, trying server: #{next_server}", self)
        reconnect(next_server, @handler.port) unless(@shutdown)
        succeed(self) # send status to handle if this is good or bad, this might not allways be a good thing.. 
      end
    end
  end
end