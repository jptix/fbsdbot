require 'lib/irc/event_constants'

module FBSDBot
  module IRC    
    module Commands
      include Constants

      def join_channels(*chans)
        chans.map { |channel, password|
          if password then
            send_raw(JOIN, channel, password)
          else
            send_raw(JOIN, channel)
          end
          channel
        } # need to map to get rid of the passwords
      end

      def connected?
        @connected
      end

      def send_identify(password)
        send_raw(NS, "IDENTIFY #{password}")
      end

      # FIXME: figure out what the server supports, possibly requires it
      # to be moved to SilverPlatter::IRC::Connection (to allow ghosting, nickchange, identify)
      def send_ghost(nickname, password)
        send_raw(NS, "GHOST #{nickname} #{password}")
      end

      # cuts the message-text into pieces of a maximum size
      # (or until the next newline if shorter)
      def normalize_message(message, limit=nil, &block)
        message.scan(/[^\n\r]{1,#{limit||LIMIT_MESSAGE}}/, &block)
      end

      # sends a privmsg to given user or channel (or multiple)
      # messages containing newline or exceeding @limit[:message_length] are automatically splitted
      # into multiple messages.

      def send_privmsg(message, *recipients)
        Log.info("sending privmsg '#{message}' to '#{recipients}'")
        normalize_message(message) { |message|
          recipients.each { |recipient|
            send_raw(PRIVMSG, recipient, message)
          }
        }
      end
      
  
      # same as privmsg except it's formatted for ACTION
      def send_action(message, *recipients)
        normalize_message(message) { |message|
          recipients.each { |recipient|
            send_raw(PRIVMSG, recipient, "\001ACTION #{message}\001")
          }
        }
      end
  
      # sends a notice to receiver (or multiple if receiver is array of receivers)
      # formatted=true allows usage of ![]-format commands (see IRCmessage.getFormatted)
      # messages containing newline automatically get splitted up into multiple messages.
      # Too long messages will be tokenized into fitting sized messages (see @limit[:message_length])
      def send_notice(message, *recipients)
        normalize_message(message) { |message|
          recipients.each { |recipient|
            send_raw(NOTICE, recipient, message)
          }
        }
      end
  
      # send a ping
      def send_ping(*args)
        send_raw(PING, *args)
      end

      ## stop

      def send_pong(*args)
        send_raw(PONG, *args)
      end

      def change_nick(nick)
        send_raw(NICK, nick)
      end

      private

      def login
        Log.info("Sending login information", self)
        send_raw(NICK, @args[:nick])
        send_raw(USER, @args[:username], 0, "*", @args[:realname])
      end

      def send_raw(*arguments)
        if arguments.last.include?(Space) || arguments.last[0] == ?: then
          arguments[-1] = ":#{arguments.last}"
        end
        write_with_eol(arguments.join(Space))
      end

      def write_with_eol(data)
        data += EOL
        send_data data
      end

    end # Commands
  end # IRC
end # FBSDBot
