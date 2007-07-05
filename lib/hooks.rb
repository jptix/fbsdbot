module FBSDBot

	module PluginSugar
	  def def_field(*names)
  	  class_eval do 
    	  names.each do |name|
      	  define_method(name) do |*args| 
        	  case args.size
          	when 0: instance_variable_get("@#{name}")
	          else    instance_variable_set("@#{name}", *args)
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
    p = new
    p.instance_eval(&block)
    Plugin.registered_plugins[name.to_sym] = p
  end

  extend PluginSugar
  def_field :author, :version, :handles
	end

### this under PLUGIN_DIR/
	Plugin.define "foo" do
  author "Daniel Bond"
  version "0.0.1"
	handles :privmsg
  
  # stuff
  def do_it(x)  # becomes a singleton method
    x * 2
  end
	end

end
