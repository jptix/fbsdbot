require "#{File.dirname(__FILE__)}/irc_nodes"
Treetop.load File.dirname(__FILE__) + "/irc.treetop"


module FBSDBot
  module IRC
    class Parser
      
      User = Struct.new(:nick, :hostmask)

      def initialize
        @parser = IRCParser.new
      end
      
      # messy!
      def parse_line(line)
        result = @parser.parse(line)
        unless result
          debugger
          puts "couldn't parse line #{line.inspect}"
        end
        
        result.value if result
      end
      
      private
      
      
      def parse_privmsg(event, msg)
        case msg
        when /\x01(.+?)\x01/
          parse_ctcp($1, event, msg)
        else
          event.type = :private_message
          event.message = msg
        end
      end
      
      def parse_ctcp(type, event, msg)
        case type
        when 'VERSION'
          event.type = :ctcp_version
        when 'PING'
          event.type = :ctcp_ping
        when 'CLIENTINFO'
          event.type =:ctcp_clientinfo
        when 'ACTION'
          event.type =:ctcp_action
        when 'FINGER'
          event.type =:ctcp_finger
        when 'TIME'
          event.type =:ctcp_time
        when 'DCC'
          event.type =:ctcp_dcc
        when 'ERRMSG'
          event.type =:ctcp_errmsg
        when 'PLAY'
          event.type =:ctcp_play
        else
          puts "unknown ctcp type #{type.inspect}"
          event.type =:ctcp
        end
            
      end
      
    end
  end
end