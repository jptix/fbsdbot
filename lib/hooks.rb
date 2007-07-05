# SYMBOLS
"pubmsg".to_sym
"privmsg".to_sym

module FBSDBot

	module PluginSugar
	  def def_field(*names)
  	  class_eval do 
    	  names.each do |name|
      	  define_method(name) do |*args| 
        	  case args.size
          	when 0: instance_variable_get("@#{name}")
	          else    instance_variable_set("@#{name}", [*args])
  	        end
    	    end
      	end
	    end
  	end
	end

	class Plugin
  @registered_plugins = {}
  class << self
    attr_reader :registered_plugins
    private :new
  end

  def self.define(name, &block)
      @name = name
    p = new
    p.instance_eval(&block)
    Plugin.registered_plugins[name.to_sym] = p
  end
  
  extend PluginSugar
  def_field :author, :version 
	end

## this under plugins/
  Plugin.define "foo" do
    author "Daniel Bond"
    version "0.0.1"
  
    # stuff
    def on_pubmsg_commands(event,line)  # becomes a singleton method
      #puts bot.inspect
      $bot.irc.send_message(event.channel, "#{event.from}, I cannot tell you my commands yet, sorry! :(")
    end
  end

end
