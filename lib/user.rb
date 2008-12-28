require "digest/sha1"

module FBSDBot
  class User
    include FBSDBot::BitMask
    
    attr_reader :nick, :user, :host, :mask
    attr_accessor :password

    FLAGS = {
      :identified     => 1,
      :bot_master     => 2,
      :channel_master => 4,
      :op             => 8,
      :voice          => 16
    }

    class << self
      attr_accessor :datastore
      
      def datastore
        @@datastore ||= YAMLUserStore.new('fbsdbot-userstore.yml')
      end
      
      def cache
        @@cache ||= Hash.new { |h, k| h[k] = User.new(*k.split(/[!@]/)) }
      end
    end
    
    def initialize(nick, user, host)
      @nick, @user, @host = nick, user, host
      @mask = 0
    end
    
    def string
      "#{@nick}!#{@user}@#{@host}"
    end
    
    def identify(pass)
      return unless pass
      pass = Digest::SHA1.hexdigest(pass)
      user = User.datastore.fetch(string)
      
      if user && user.password == pass
        user.set_flag(:identified)
        user.save
        return user
      end
    end
    
    def password=(string)
      @password = Digest::SHA1.hexdigest(string)
    end
    
    def save
      User.datastore.save(self)
    end
    
    def identified?
      has_flag? :identified
    end
    
    def bot_master?
      has_flag? :bot_master
    end
    
    def channel_master?
      # TODO: need to figure out how to solve flags in several channels
      has_flag? :channel_master
    end
    
    def voice?
      # TODO: need to figure out how to solve flags in several channels
      has_flag? :voice
    end
    
  end
end