require "fileutils"

module FBSDBot
  class YAMLUserStore
    
    def initialize(file)
      @file = file
      create_file unless File.exist?(@file)
      @data = YAML.load_file(@file) || {}
      
      save_master ### FIXME
    end
    
    def save(user)
      check_type user
      @data[user.string] = user
      persist
    end
   
    def fetch(user_string)
      @data[user_string]
    end
    
    private
    
    def check_type(user)
      unless user.is_a?(User)
        raise TypeError, "can't convert #{user.inspect}:#{user.class} into User"
      end
    end
    
    def persist
      File.open(@file, "w") { |file| YAML.dump(@data, file) }
    end
   
    def create_file
      FileUtils.mkdir_p(File.dirname(@file))
      FileUtils.touch(@file)
    end
    
    def save_master
      return unless $config && $config[:master]
      
      nick, user, host = $config[:master].values_at(:nick, :user, :host)
      master = User.new(nick, user, host)
      master.password = $config[:master][:password]
      master.set_flag(:bot_master)
      save(master)
    end
    
  end
end