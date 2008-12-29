require "digest/sha1"

module FBSDBot
  class User
    include FBSDBot::BitMask
    
    attr_reader :bitmask
    attr_accessor :nick, :user, :host, :hostmask_exp

    FLAGS = {
      :admin => 1,
    }

    class << self

      def datastore
        @@datastore ||= YAMLUserStore.new('fbsdbot-userstore.yml')
      end
      
      def datastore=(ds)
        @@datastore = ds
      end
      
      def cache
        @@cache ||= Hash.new { |h, k| h[k] = User.new(*k.split(/[!@]/)) }
      end
    end
    
    def initialize(nick, user, host)
      @nick, @user, @host = nick, user, host
      @bitmask = 0
    end
    
    def =~(other)
      return true if self == other
      return true if self.hostmask == other.hostmask
      return true if hostmask =~ other.hostmask_exp
      return true if @hostmask_exp =~ other.hostmask
      return false
    end
    
    def hostmask
      "#{@nick}!#{@user}@#{@host}"
    end
    
    def save
      User.datastore.save(self)
    end
    
    def admin?
      has_flag? :admin
    end
    
  end
end