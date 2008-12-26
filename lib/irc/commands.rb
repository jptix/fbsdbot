module FBSDBot
  module IRC
    module Constants
      EOL     = "\r\n".freeze
      EXP_EOL = /#{EOL}$/.freeze
      # A single space character
      Space   = " ".freeze
      # AWAY command
      AWAY    = "AWAY".freeze
      # JOIN command
      JOIN    = "JOIN".freeze
      # KICK command
      KICK    = "KICK".freeze
      # MODE command
      MODE    = "MODE".freeze
      # NICK command
      NICK    = "NICK".freeze
      # NOTICE command
      NOTICE  = "NOTICE".freeze
      # NS command
      NS      = "NS".freeze
      # PART command
      PART    = "PART".freeze
      # PASS command
      PASS    = "PASS".freeze
      # PING command
      PING    = "PING".freeze
      # PONG command
      PONG    = "PONG".freeze
      # PRIVMSG command
      PRIVMSG = "PRIVMSG".freeze
      # USER command
      USER    = "USER".freeze
      # QUIT command
      QUIT    = "QUIT".freeze
      # WHO command
      WHO     = "WHO".freeze
      # WHOIS command
      WHOIS   = "WHOIS".freeze
    end
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
            message.scan(/[^\n\r]{1,#{limit||@limit[:message_length]}}/, &block)
          end

          # sends a privmsg to given user or channel (or multiple)
          # messages containing newline or exceeding @limit[:message_length] are automatically splitted
          # into multiple messages.
          
          def send_privmsg(message, *recipients)
            normalize_message(message) { |message|
              recipients.each { |recipient|
                send_raw(PRIVMSG, recipient, message)
              }
            }
          end
          
          private
          
          def login
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

    end
  end
end