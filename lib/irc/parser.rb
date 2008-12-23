module FBSDBot
  module IRC
    class Parser
      
      User = Struct.new(:nick, :hostmask)
      
      # messy!
      def parse_line(line)
        case line
        when %r{(:\S+)? ([A-Z0-9 ]+?)( [#\w ]+? )?:(.+)}
          _, from, type, to, msg = *$~
        else
          $stderr.puts "can't parse #{line.inspect}"
        end
        
        p :capts => $~.captures if $~
        
        type = type.to_s.strip
        event = Event.new
        
        case type
        when 'PRIVMSG'
          parse_privmsg(event, msg)
        when 'JOIN'
          event.type = :join
        when 'PART'
          event.type = :part
        when 'QUIT'
          event.type = :quit
        when 'PING'
          event.type = :ping
        when '376'
          event.type = :end_of_motd
        else
          puts(err = "unknown event type #{type.inspect} for #{line.inspect}")
          event.type = type.downcase    
        end
        
        event.user = from
        event.to = to
        
        event
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