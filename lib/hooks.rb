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
	
	def self.list_plugins
		@registered_plugins.each {|i,p| puts "  - #{i} (#{p.version}) by: #{p.author}"}
	end

  def self.define(name, &block)
    @name = name
    p = new
    p.instance_eval(&block)
    Plugin.registered_plugins[name.to_sym] = p
  end
  
  extend PluginSugar
  def_field :author, :version, :commands 
	end

end
