# encoding: utf-8
require 'lib/irc/constants'

module FBSDBot
  module IRC
    module Commands
      include Constants

      def send_join(*channels)
        return if channels[0].nil?
        channels.map { |channel, password|
          if password then
            send_raw(JOIN, channel, password)
          else
            send_raw(JOIN, channel)
          end
          channel
        } # need to map to get rid of the passwords
      end

      # part specified channels
      # returns the channels parted from.
      def send_part(reason=nil, *channels)
        if channels.empty?
          channels = [reason]
          reason   = nil
        end # FIXME: leave this overloading in place or remove?
        reason ||= "leaving"

        # some servers still can't process lists of channels in part
        channels.each { |channel|
          send_raw(PART, channel, reason)
        } # each returns receiver
      end

      def connected?
        @connected
      end
      
      def reconnect?
        !@shutdown
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
      
      # Give Op to user in channel
      # User can be a nick or IRC::User, either one or an array.
      def send_multiple_mode(channel, pre, flag, targets)
        (0...targets.length).step(12) { |i|
          slice = targets[i,12]
          send_raw(MODE, channel, "#{pre}#{flag*slice.length}", *slice)
        }
      end

      # sends a privmsg to given user or channel (or multiple)
      # messages containing newline or exceeding @limit[:message_length] are automatically splitted
      # into multiple messages.

      def send_privmsg(message, *recipients)
        Log.debug("sending privmsg '#{message}' to '#{recipients}'")
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
      
      # set your status to away with reason 'reason'
      def send_away(reason=nil)
        return back if reason.nil?
        send_raw(AWAY, reason)
      end
      
      # reset your away status to back
      def send_back
        send_raw(AWAY)
      end
      
      # Send a "who" to channel/user
      def send_who(target)
        send_raw(WHO, target)
      end
  
      # Send a "whois" to server
      def send_whois(nick)
        send_raw(WHOIS, nick)
      end
  
      # send the quit message to the server
      def send_quit(reason="leaving")
        @shutdown = true # good idea to do this first..
        send_raw(QUIT, reason)
        close_connection_after_writing # after telling the server, we can just close the connection.
      end
  
      # send a ping
      def send_ping(*args)
        send_raw(PING, *args)
      end
      
      # Give Op to user in channel
      # User can be a nick or IRC::User, either one or an array.
      def send_op(channel, *users)
        send_multiple_mode(channel, '+', 'o', users)
      end
  
      # Take Op from user in channel
      # User can be a nick or IRC::User, either one or an array.
      def send_deop(channel, *users)
        send_multiple_mode(channel, '-', 'o', users)
      end
  
      # Give voice to user in channel
      # User can be a nick or IRC::User, either one or an array.
      def send_voice(channel, *users)
        send_multiple_mode(channel, '+', 'v', users)
      end
  
      # Take voice from user in channel.
      # User can be a nick or IRC::User, either one or an array.
      def send_devoice(channel, *users)
        send_multiple_mode(channel, '-', 'v', users)
      end
  
      # Set ban in channel to mask
      def send_ban(channel, *masks)
        send_multiple_mode(channel, '+', 'b', masks)
      end
  
      # Remove ban in channel to mask
      def send_unban(channel, *masks)
        send_multiple_mode(channel, '-', 'b', masks)
      end
      
      # kick user in channel with reason
      def send_kick(user, channel, reason)
        send_raw(KICK, channel, user, reason)
      end
      
      # send a mode command to a channel
      def send_mode(channel, *mode)
        if mode.empty? then
          send_raw(MODE, channel)
        else
          send_raw(MODE, channel, *mode)
        end
      end

      def send_pong(*args)
        send_raw(PONG, *args)
      end

      def send_nick(nick)
        send_raw(NICK, nick)
      end

      private

      def login
        Log.info("Sending login information", self)
        send_raw(NICK, @handler.nick)
        send_raw(USER, @handler.username, 0, "*", @handler.realname)
      end

      def send_raw(*arguments)
        if arguments.last.include?(Space) || arguments.last[0,1] == ":"
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
