require "digest/sha1"

module FBSDBot
  class User
    attr_reader :nick, :user, :host
    attr_accessor :password

    class << self
      attr_accessor :datastore
      
      def datastore
        @@datastore ||= YAMLUserStore.new('fbsdbot-userstore.yml')
      end
    end
    
    def initialize(nick, user, host)
      @nick, @user, @host = nick, user, host
    end
    
    def string
      "#{@nick}!#{@user}@#{@host}"
    end
    
    def identify(pass)
      return unless pass
      user = self.class.datastore.fetch(string)
      if user && user.password == Digest::SHA1.hexdigest(pass)
        return user
      end
    end
    
    def password=(string)
      @password = Digest::SHA1.hexdigest(string)
    end
    
  end
end