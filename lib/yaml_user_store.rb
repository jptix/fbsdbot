require "fileutils"

module FBSDBot
  class YAMLUserStore
    
    def initialize(file)
      @file = file
      create_file unless File.exist?(@file)
      @data = YAML.load_file(@file) || []
      
      save_master ### FIXME
    end
    
    def save(user)
      check_type user
      @data << user
      @data.uniq!
      persist
    end
   
    def fetch(opts = {})
      Log.warn(:fetching => opts)
      if user = opts[:user]
        @data.find { |u| u =~ user  }
      elsif rx = opts[:regexp]
        @data.find { |u| u.hostmask =~ rx }
      elsif hm = opts[:hostmask]
        @data.find { |u| u.hostmask == hm || u.hostmask_exp =~ hm }
      else
        raise "bad parameters: #{opts.inspect}"
      end
    end
    
    def fetch_all
      @data
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
      rx = $config[:master][:hostmask_exp]
      
      return if fetch(:regexp => rx)
      
      master = User.new(nil, nil, nil)
      master.hostmask_exp = rx
      master.set_flag(:admin)
      Log.debug(:master => master)
      save(master)
    end
    
  end
end