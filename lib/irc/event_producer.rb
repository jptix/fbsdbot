# encoding: utf-8
require "lib/irc/events/event"
require "lib/irc/events/replyable"
require "lib/irc/events/private_message_event"
require "lib/irc/events/ctcp_events"
require "lib/irc/events/disconnect_event"
require "lib/irc/events/motd_event"
require "lib/irc/events/motd_start_event"
require "lib/irc/events/end_of_motd_event"
require "lib/irc/events/no_motd_event"
require "lib/irc/events/join_event"
require "lib/irc/events/kick_event"
require "lib/irc/events/mode_event"
require "lib/irc/events/names_event"
require "lib/irc/events/ping_event"
require "lib/irc/events/nick_event"
require "lib/irc/events/nickname_in_use_event"
require "lib/irc/events/end_of_names_event"
require "lib/irc/events/notice_event"
require "lib/irc/events/quit_event"
require "lib/irc/events/part_event"
require "lib/irc/events/end_of_whois_event"
require "lib/irc/events/whois_user_event"
require "lib/irc/events/whois_server_event"
require "lib/irc/events/whois_idle_event"
require "lib/irc/events/whois_channels_event"
require "lib/irc/events/whois_operator_event"
require "lib/irc/events/shutdown_event"
require "lib/irc/events/topic_event"
require "lib/irc/events/topic_info_event"
require "lib/irc/events/unavailable_resource_event"

module FBSDBot
  module IRC
    class EventProducer

      COMMANDS = {
        '311'    => WhoisUserEvent,
        '312'    => WhoisServerEvent,
        '313'    => WhoisOperatorEvent,
        '317'    => WhoisIdleEvent,
        '318'    => EndOfWhoisEvent,
        '319'    => WhoisChannelsEvent,
        '332'    => TopicEvent,
        '333'    => TopicInfoEvent,
        '353'    => NamesEvent,
        '366'    => EndOfNamesEvent,
        '372'    => MotdEvent,
        '375'    => MotdStartEvent,
        '376'    => EndOfMotdEvent,
        '422'    => NoMotdEvent,
        '433'    => NicknameInUseEvent,
        '437'    => UnavailableResourceEvent,
        'JOIN'   => JoinEvent,
        'KICK'   => KickEvent,
        'NICK'   => NickEvent,
        'MODE'   => ModeEvent,
        'NOTICE' => NoticeEvent,
        'PART'   => PartEvent,
        'PING'   => PingEvent,
        'TOPIC'  => TopicEvent,
        'QUIT'   => QuitEvent,
      }

      CTCP_COMMANDS = {
        'ACTION'     => CTCPActionEvent,
        'CLIENTINFO' => CTCPClientInfoEvent,
        'DCC'        => CTCPDccEvent,
        'ERRMSG'     => CTCPErrorMessageEvent,
        'FINGER'     => CTCPFingerEvent,
        'PING'       => CTCPPingEvent,
        'PLAY'       => CTCPPlayEvent,
        'TIME'       => CTCPTimeEvent,
        'VERSION'    => CTCPVersionEvent,
      }

      def initialize(worker)
        @worker = worker
        @chardet = ICU::CharDet::Detector.new
      end

      def parse_line(line)
        Log.debug :incoming => line
        result = Parser.parse_message(line)
        return unless result

        # need to detect the correct input encoding, and convert to UTF-8
        result.each_value { |v| fix_encoding(v) }

        # we might need the raw input though, so store that as well
        result[:raw] = line

        return hash_to_event(result)
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
          Log.debug "unknown event for #{hash.inspect}", @worker
        end
      end

      def create_ctcp(type, hash)
        if event_class = CTCP_COMMANDS[type]
          return create(event_class, hash)
        else
          Log.debug "unknown ctcp type #{type.inspect}", @worker
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

      ICU_TO_RUBY      = {
        "ISO-8859-8-I" => "ISO-8859-1",
        "ISO-2022-KR"  => "stateless-ISO-2022-JP", # no idea if this is correct
        "ISO-2022-CN"  => "stateless-ISO-2022-JP" # no idea if this is correct
      }


      INTERNAL_ENCODING = "UTF-8"

      def fix_encoding(data)
        # this would ideally happen in the C parser, using ICU directly
        case data
        when String
          if data.ascii? || data.dup.force_encoding(INTERNAL_ENCODING).valid_encoding?
            data.force_encoding(INTERNAL_ENCODING)
          elsif match = @chardet.detect(data)
            input_encoding = ICU_TO_RUBY[match.name] || match.name
            Log.warn [match, input_encoding].inspect
            data.force_encoding(input_encoding).encode!(INTERNAL_ENCODING)
          else
            # try some common encodings
            tmp = data.dup
            if tmp.force_encoding("ISO-8859-1").valid_encoding?
              data.force_encoding("ISO-8859-1").encode!(INTERNAL_ENCODING)
            else
              Log.warn "removing non-ASCII! #{data.inspect}"
              data.gsub!(/[^A-z]/, '').force_encoding(INTERNAL_ENCODING)
            end
            Log.info "unknown charset: #{data.inspect}"
          end
        when Array
          data.each { |e| fix_encoding(e) }
        when NilClass
          # ignored
        else
          raise "can't fix_encoding for: #{data.inspect}"
        end
      end

    end # EventProducer
  end # IRC
end # FBSDBot
