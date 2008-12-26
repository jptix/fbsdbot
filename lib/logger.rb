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

    def debug(msg)
      log :debug, msg
    end

    def info(msg)
      log :info, msg
    end
    
    def warn(msg)
      log :warn, msg
    end
    
    def error(msg)
      log :error, msg
    end
    
    def fatal(msg)
      log :fatal, msg
    end
    
    private
    
    def log(type, msg)
      return unless LOG_LEVELS[type] >= LOG_LEVELS[@level]
      
      msg = msg.inspect if Hash === msg
      @out.puts "#{Time.now.strftime("%F %T")} :: #{type} - #{msg}"
    end
  end
end
