module FBSDBot

  class Plugin
    @registered_plugins = {}
    @event_handlers = Hash.new { |h, k| h[k] = [] }
    
    class << self
      attr_reader :registered_plugins
      private :new

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

      def list_plugins
        @registered_plugins.each {|i,p| Log.info "Written by #{p.author}", p}
      end

      def define(name, &block)
        plugin = new
        plugin.instance_eval(&block)
        
        commands = []
        
        (plugin.methods - Object.methods).each do |method|
          method = method.to_s # will be symbols in 1.9
          
          if method =~ /on_(.+)/
            @event_handlers[$1] << plugin
            commands << $1 if method =~ /on_cmd_(.+)/
          end
        end
        
        plugin.instance_eval do
           name(name) 
           commands(commands)
         end
        
        
        Log.debug(@event_handlers, self)
        @registered_plugins[name.to_sym] = plugin
      end

      def send_event(event)
        event_type = event.type
        
        if event.command?
          event_type = "cmd_#{event.command}"
        end
        
        @event_handlers[event_type].each do |handler|
          handler.send "on_#{event_type}", event
        end
      end

    end # class << self

    def to_s
      "#<FBSDBot::Plugin: #{@name}, #{@version}>"
    end

    def_field :name, :author, :version, :commands
  end

end
