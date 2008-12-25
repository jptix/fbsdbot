require "#{File.dirname(__FILE__)}/irc_nodes"
Treetop.load File.dirname(__FILE__) + "/common.treetop"
Treetop.load File.dirname(__FILE__) + "/params.treetop"
Treetop.load File.dirname(__FILE__) + "/irc.treetop"


module FBSDBot
  module IRC
    class Parser
      
      User = Struct.new(:nick, :hostmask)

      def initialize
        @parser = IRCParser.new
      end
      
      def parse_line(line)
        p :incoming => line
        result = @parser.parse(line)
        
        if result
          hash_to_event(result.value)
        else
          puts "ignoring: #{line.inspect}"
        end
      end
      
      private
      
      def hash_to_event(hash)
        case hash[:command]
        when 'PRIVMSG'
          parse_privmsg(hash)
        when 'PING'
          Event.new(:ping, :from => hash[:prefix], :message => hash[:params][:message])
        when '376'
          Event.new(:end_of_motd)
        else
          "unknown event for #{hash.inspect}"
        end
      end
      
      def parse_privmsg(hash)
        event = Event.new(:private_message, :from => hash[:prefix])
        
        case hash[:params]
        when /\x01(.+?)\x01/
          parse_ctcp($1, event)
        else
          event.type    = :private_message
          event.params  = hash[:params]
          event.sender  = hash[:prefix]
        end
        
        event
      end
      
      def parse_ctcp(type, event)
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