require "lib/irc/events/event"
require "lib/irc/events/replyable"
require "lib/irc/events/private_message_event"
require "lib/irc/events/ctcp_events"
require "lib/irc/events/disconnect_event"
require "lib/irc/events/motd_event"
require "lib/irc/events/end_of_motd_event"
require "lib/irc/events/join_event"
require "lib/irc/events/names_event"
require "lib/irc/events/ping_event"
require "lib/irc/events/nickname_in_use_event"
require "lib/irc/events/end_of_names_event"
require "lib/irc/events/notice_event"
require "lib/irc/events/quit_event"
require "lib/irc/events/part_event"


module FBSDBot
  module IRC
    class EventProducer

      COMMANDS = {
        'PING'   => PingEvent,
        'JOIN'   => JoinEvent,
        'PART'   => PartEvent,
        'NOTICE' => NoticeEvent,
        'QUIT'   => QuitEvent,
        '372'    => MotdEvent,
        '376'    => EndOfMotdEvent,
        '353'    => NamesEvent,
        '433'    => NicknameInUseEvent,
        '366'    => EndOfNamesEvent,
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

      def initialize(worker)
        @worker = worker
      end

      def parse_line(line)
        Log.debug :incoming => line
        result = Parser.parse_message(line)
        
        return hash_to_event(result) if result
        return nil
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
          Log.warn "unknown event for #{hash.inspect}", @worker
        end
      end

      def create_ctcp(type, hash)
        if event_class = CTCP_COMMANDS[type]
          return create(event_class, hash)
        else
          Log.warn "unknown ctcp type #{type.inspect}", @worker
          return nil
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
        type.new(@worker, opts)
      end

    end # EventProducer
  end # IRC
end # FBSDBot
