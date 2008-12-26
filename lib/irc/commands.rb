module FBSDBot
  module IRC
    module Constants
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
#            channel = "\##{channel}" unless channel[/^#/]
              chans.map { |channel, password|
                if password then
                  send_raw(JOIN, channel, password)
                else
                  send_raw(JOIN, channel)
                end
                channel
              } # need to map to get rid of the passwords
          end

          def send_message(recipient, message)
            @socket.send_privmsg(message, recipient)
          end

          def send_notice(recipient, notice)
            @socket.send_notice(notice, recipient)
          end
    end
  end
end