module FBSDBot
  module IRC
    class EventProducer
      
      User = Struct.new(:nick, :hostmask)

      def initialize
      end
      
      def parse_line(line)
        p :incoming => line
        result = Parser.parse(line)
        
        if result
          hash_to_event(result)
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
          Event.new(:ping, :from => hash[:nick], :message => hash[:params].first)
        when 'JOIN'
          Event.new(:join, :from => hash[:nick])
        when '376'
          Event.new(:end_of_motd)
        when '353'
          Event.new(:names_reply, :message => hash[:params].join(' '))
        else
          puts "unknown event for #{hash.inspect}"
        end
      end
      
      def parse_privmsg(hash)
        event = Event.new(:private_message, :from => hash[:nick])
        
        case hash[:params]
        when /\x01(.+?)\x01/
          parse_ctcp($1, event)
        else
          event.type    = :private_message
          event.to      = hash[:params].first
          event.channel  = event.to
          event.message = hash[:params].last
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