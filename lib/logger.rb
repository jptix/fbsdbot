module FBSDBot
  class Logger

    LOG_LEVELS = {
      :debug => 0,
      :info  => 1,
      :warn  => 2,
      :error => 3,
      :fatal => 4
    }

    def initialize(out = $stderr)
      @out = out
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
      return unless LOG_LEVELS[type] >= LOG_LEVELS[@level]
      
      msg = msg.inspect if Hash === msg
      @out.puts "#{Time.now.strftime("%F %T")} (#{type}) #{obj} :: #{msg}"
    end
  end
end
