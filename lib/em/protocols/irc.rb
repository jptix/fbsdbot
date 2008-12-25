module EventMachine
  module Protocols
    class IrcClient < Connection
      include EventMachine::Deferrable

      MaxRawLength = 400
      MaxMsgLength = 300

      def self.connect(args = {})
        args[:port] ||= 6667
        args[:username] ||= args[:nick]
        args[:realname] ||= args[:nick]
        EventMachine::connect( args[:host], args[:port], self) {|c| c.instance_eval {@args = args} }
      end
      
      def post_init
        @start_time = Time.now
        @message = ""
      end
      
      def connection_completed
        @connected = true
        login @args
      end
      
      def login(args)
        puts "sending login to server with args:"
        send_data("NICK #{args[:nick]}\r\n")
        send_data("USER #{args[:username]} 0 * #{args[:realname]}\r\n")
      end
      
      def receive_data(data)
        # check if we where given more than one line
        lines = data.split("\r\n")
        if lines.empty?
          #single newline char given, this must be handled!
#          puts @message
        else
          lines.each do |line|
            puts "## #{line}"
          end
        end
#        dispatch
      end
      
      def unbind
        puts "connection to #{@args[:host]}:#{@args[:port]} died"
      end
      
    end
  end
end