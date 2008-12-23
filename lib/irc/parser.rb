module FBSDBot
  module IRC
    class Parser
      
      def parse_line(line)
        match, from, type, to, msg = *line.match(%r{(\S+?) ([A-Z0-9]+) (\w+) :(.+)})
        
        unless match
          return puts("could not parse #{line.inspect}")
        end
        
        case type
        when 'PRIVMSG'
          return privmsg(from, to, msg)
        else
          puts("unknown type #{type}")
        end
        
        return nil
      end
      
      private
      
      def privmsg(from, to, msg)
        case msg
        when /\x01(.+?)\x01/
          ctcp($1, from, to)
        else
          [:private_message, from, to, msg]
        end
      end
      
      def ctcp(type, from, to)
        case type
        when 'VERSION'
          [:ctcp_version, from, to]
        else
          puts "unknown ctcp type #{type.inspect}"
        end
      end
      
    end
  end
end