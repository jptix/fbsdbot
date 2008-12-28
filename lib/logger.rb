module FBSDBot
  class Logger
    attr_reader :level

    LOG_LEVELS = {
      :debug => 0,
      :info  => 1,
      :warn  => 2,
      :error => 3,
      :fatal => 4
    }

    def initialize
      @level = :debug
    end
    
    def level=(level)
      unless LOG_LEVELS.keys.include?(level)
        raise "log level must be one of #{LOG_LEVELS.keys.join(', ')}"
      end
      
      @level = level
    end

    def debug(msg, obj = nil)
      log :debug, msg, obj
    end

    def info(msg, obj = nil)
      log :info, msg, obj
    end
    
    def warn(msg, obj = nil)
      log :warn, msg, obj
    end
    
    def error(msg, obj = nil)
      log :error, msg, obj
    end
    
    def fatal(msg, obj = nil)
      log :fatal, msg, obj
    end
    
    private
    
    def log(type, msg, obj)
      this_level    = LOG_LEVELS[type]
      current_level = LOG_LEVELS[@level]
      
      return unless this_level >= current_level
      
      out = this_level >= LOG_LEVELS[:warn] ? $stderr : $stdout 
      
      msg = msg.inspect if [Hash, Array].include?(msg.class)
      out.puts "#{Time.now.strftime("%F %T")} (#{type}) #{obj} :: #{msg}"
    end
  end
end
