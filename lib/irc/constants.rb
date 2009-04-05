# encoding: utf-8
module FBSDBot
  module IRC
    module Constants
      EOL     = "\r\n".freeze
      
      EXP_EOL = /#{EOL}$/.freeze
      
      LIMIT_MESSAGE = 300.freeze
      
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
  end
end
