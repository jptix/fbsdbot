require 'lib/irc/commands.rb'

module FBSDBot
  module IRC
    class EMCore < EventMachine::Connection
      attr_reader :args
      include EventMachine::Deferrable
      include Commands
      include Constants

      def self.connect(args = {})
        args[:port]     ||= 6667
        args[:username] ||= args[:nick]
        args[:realname] ||= args[:nick]
        EventMachine::connect( args[:host], args[:port], self) do |instance| 
          instance.instance_eval {
            @args = args
            @event_producer = EventProducer.new(self)
            Log.info("Connecting to server", self)
          }
        end
      end
      
      def to_s
        "<Worker ##{object_id}::(#{@connected ? "C" : "D"}:#{@args[:host]})>"
      end
      
      def post_init
        @start_time = Time.now
        @buffer = ""
        @connected = false
      end
      
      def connection_completed
        @connected = true
        Log.info("Sending login information", self)
        login
      end
      
      def receive_data(data)
        data.each_line(EOL) do |line|
          line =~ EXP_EOL ? dispatch_message(line) : @buffer << line
        end
      end

      def dispatch_message(line)
        message = @buffer.empty? ? line : @buffer + line
        @buffer = "" # important, reset buffer!

        e = @event_producer.parse_line(line)
        if e.is_a?(Event)
          p e.inspect
        end
      end
     
      def unbind
        @connected = false
        Log.info("Worker id##{self.object_id}(#{@args[:host]}): quiting normally")
        succeed(self) # send status to handle if this is good or bad, this might not allways be a good thing.. 
      end
      
    end
  end
end