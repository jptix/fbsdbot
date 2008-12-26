require "#{File.dirname(__FILE__)}/events/event"
require "#{File.dirname(__FILE__)}/events/private_message_event"
require "#{File.dirname(__FILE__)}/events/ctcp_events"
require "#{File.dirname(__FILE__)}/events/disconnect_event"
require "#{File.dirname(__FILE__)}/events/end_of_motd_event"
require "#{File.dirname(__FILE__)}/events/join_event"
require "#{File.dirname(__FILE__)}/events/names_event"
require "#{File.dirname(__FILE__)}/events/ping_event"
require "#{File.dirname(__FILE__)}/events/nickname_in_use_event"


module FBSDBot
  module IRC
    class EventProducer
      
      COMMANDS = {
        'PING' => PingEvent,
        'JOIN' => JoinEvent,
        '376'  => EndOfMotdEvent,
        '353'  => NamesEvent,
        '433'  => NicknameInUseEvent,
      }
      
      CTCP_COMMANDS = {
        'VERSION'    => CTCPVersionEvent,
        'PING'       => CTCPPingEvent,
        'CLIENTINFO' => CTCPClientInfoEvent,
        'ACTION'     => CTCPActionEvent,
        'FINGER'     => CTCPFingerEvent,
        'TIME'       => CTCPTimeEvent,
        'DCC'        => CTCPDccEvent,
        'ERRMSG'     => CTCPErrorMessageEvent,
        'PLAY'       => CTCPPlayEvent
      }

      def initialize(connection)
        @conn = connection
      end
      
      def parse_line(line)
        result = Parser.parse(line)
        
        if result
          hash_to_event(result)
        else
          puts "ignoring: #{line.inspect}"
        end
      end
      
      def disconnect_event
        create DisconnectEvent
      end
      
      private
      
      def hash_to_event(hash)
        command = hash[:command]
        
        if event_class = COMMANDS[command]
          return create(event_class, hash)
        end
        
        case command
        when 'PRIVMSG'
          create_privmsg(hash)
        else
          puts "unknown event for #{hash.inspect}"
        end
      end
      
      def create_ctcp(type, hash)
        if event_class = CTCP_COMMANDS[type]
          return create(event_class, hash)
        else
          puts "unknown ctcp type #{type.inspect}"
        end
      end

      def create_privmsg(hash)
        case hash[:params].last
        when /\x01([A-Z]+)/
          create_ctcp($1, hash)
        else
          create PrivateMessageEvent, hash
        end
      end
            
      def create(type, opts = {})
        type.new(@conn, opts)
      end
      
    end # EventProducer
  end # IRC
end # FBSDBot