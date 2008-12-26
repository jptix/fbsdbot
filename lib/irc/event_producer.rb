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
      
      User = Struct.new(:nick, :hostmask)

      def initialize(connection)
        @conn = connection
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
      
      def disconnect_event
        create DisconnectEvent
      end
      
      private
      
      def hash_to_event(hash)
        case hash[:command]
        when 'PRIVMSG'
          create_privmsg(hash)
        when 'PING'
          create PingEvent, hash
        when 'JOIN'
          create JoinEvent, hash
        when '376'
          create EndOfMotdEvent, hash
        when '353'
          create NamesEvent, hash
        when '433'
          create NicknameInUseEvent, hash
        else
          puts "unknown event for #{hash.inspect}"
        end
      end
      
      def create_privmsg(hash)
        case hash[:params].first
        when /\x01(.+?)\x01/
          create_ctcp($1, hash)
        else
          create PrivateMessageEvent, hash
        end
      end
      
      def create_ctcp(type, hash)
        case type
        when 'VERSION'
          create CTCPVersionEvent, hash
        when 'PING'
          create CTCPPingEvent, hash
        when 'CLIENTINFO'
          create CTCPClientInfoEvent, hash
        when 'ACTION'
          create CTCPActionEvent, hash
        when 'FINGER'
          create CTCPFingerEvent, hash
        when 'TIME'
          create CTCPTimeEvent, hash
        when 'DCC'
          create CTCPDccEvent, hash
        when 'ERRMSG'
          create CTCPErrorMessageEvent, hash
        when 'PLAY'
          create CTCPPlayEvent, hash
        else
          raise "unknown ctcp type #{type.inspect}"
        end
      end
      
      def create(type, opts = {})
        type.new(@conn, opts)
      end
      
    end # EventProducer
  end # IRC
end # FBSDBot