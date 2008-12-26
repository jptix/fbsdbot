module FBSDBot
  module IRC
    class EMCore < EventMachine::Connection
      attr_reader :args
      include EventMachine::Deferrable
      include Commands

      MaxRawLength = 400
      MaxMsgLength = 300
      
      EOL    = "\r\n"
      EXP_EOL = /#{EOL}$/

      def self.connect(args = {})
        args[:port] ||= 6667
        args[:username] ||= args[:nick]
        args[:realname] ||= args[:nick]
        EventMachine::connect( args[:host], args[:port], self) {|c| c.instance_eval {@args = args;} }
      end
      
      def post_init
        @start_time = Time.now
        @buffer = ""
      end
      
      def connection_completed
        @connected = true
        login
      end
      
      def login
        puts "sending login to server with args:"
        send_data("NICK #{@args[:nick]}\r\n")
        send_data("USER #{@args[:username]} 0 * #{@args[:realname]}\r\n")
      end
      
      def receive_data(data)
        data.each_line(EOL) do |line|
          line =~ EXP_EOL ? dispatch_message(line) : @buffer << line
        end
      end

      def dispatch_message(line)
        client_out = @buffer.empty? ? line : @buffer + line
        @buffer = "" # important, reset buffer!
                
        p :dispatch => client_out
      end

      
      def unbind
        puts "== Connection id##{self.object_id}(#{@args[:host]}): quiting normally"
        succeed(self) # send status to handle if this is good or bad, good in this case.. 
      end
      
    end
  end
end