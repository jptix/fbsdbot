# encoding: utf-8
module FBSDBot
  class Logger
    attr_reader :level
    attr_accessor :color
    
    LOG_LEVELS = {
      :debug => 0,
      :info  => 1,
      :warn  => 2,
      :error => 3,
      :fatal => 4,
      :off   => 5
    }

    def initialize
      @level = :debug
      @color = false
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
      return if @level == :off
      
      this_level    = LOG_LEVELS[type]
      current_level = LOG_LEVELS[@level]
      
      return unless this_level >= current_level
      
      out, red = this_level >= LOG_LEVELS[:warn] ? [$stderr,true] : [$stdout,false]
      msg = msg.inspect unless msg.respond_to?(:to_str)
      
      if @color && out.tty?
        out.puts "\e[90m#{Time.now.strftime("%F %T")}\e[0m (\e[#{red ? '31' : '33'}m#{type}\e[0m) #{obj} :: \e[1m#{msg}\e[0m"
      else
        out.puts "#{Time.now.strftime("%F %T")} (#{type}) #{obj} :: #{msg}"
      end
    end
    
    
  end
end
