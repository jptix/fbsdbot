# encoding: utf-8
require "digest/sha1"

module FBSDBot
  class User
    include FBSDBot::BitMask
    
    attr_reader :bitmask
    attr_accessor :nick, :user, :host, :hostmask_exp

    FLAGS = {
      :master => 1 << 0,
      :admin  => 1 << 1,
    }
    
    EMPTY_HOSTMASK = "!@"

    class << self
      def datastore
        @@datastore ||= YAMLUserStore.new('fbsdbot-userstore.yml')
      end
      
      def datastore=(ds)
        @@datastore = ds
      end
      
      def cache
        @@cache ||= Hash.new do |h, k|
          nick, user, host = k.split(/[!@]/)
          h[k] = User.new(:nick => nick, :user => user, :host => host)
        end
      end
    end
    
    def initialize(opts)
      @bitmask = 0
      @hostmask_exp = nil
      @nick, @user, @host = nil
      process_options opts
    end
    
    def update(nick, user, host)
      if @hostmask_exp && @hostmask_exp !~ (str = "#{nick}!#{user}@#{host}") 
        raise HostmaskMismatchError, "#{str.inspect} does not match #{@hostmask_exp.inspect}"
      end
      @nick, @user, @host = nick, user, host
    end
    
    def =~(other)
      return true if self == other
      return true if self.hostmask == other.hostmask
      return true if hostmask =~ other.hostmask_exp
      return true if @hostmask_exp =~ other.hostmask
      return false
    end
    
    def hostmask
      str = "#{@nick}!#{@user}@#{@host}"
      return str unless str == EMPTY_HOSTMASK
    end
    
    def hostmask_exp=(regexp)
      raise TypeError unless regexp.is_a?(Regexp)
      
      if hostmask != "!@" && regexp !~ hostmask
        raise HostmaskMismatchError, "#{hostmask.inspect} does not match #{regexp.inspect}"
      end
      
      @hostmask_exp = regexp
    end
    
    def save
      User.datastore.save(self)
      self
    end
    
    def admin?
      has_flag? :admin
    end
    
    def master?
      has_flag? :master
    end
    
    private
    
    def process_options(opts)
      raise TypeError, "expected Hash" unless opts.is_a?(Hash)
      values = opts.values_at(:nick, :user, :host).compact
      hostmask_exp = opts[:hostmask_exp]
      
      if values.size != 3
        if hostmask_exp.nil?
          raise ArgumentError, "options hash should include either [:nick, :user, :host] or :hostmask_exp"
        end
        @hostmask_exp = hostmask_exp
      else
        update(*values)
      end
    end
    
  end
end
