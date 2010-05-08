# encoding: utf-8
module FBSDBot

  class Plugin
    include FBSDBot::Helpers

    class << self
      attr_reader :registered_plugins
      private :new

      def def_field(*names)
        class_eval do
          names.each do |name|
            define_method(name) do |*args|
              case args.size
              when 0 then instance_variable_get("@#{name}")
              when 1 then instance_variable_set("@#{name}", args.first)
              else
                instance_variable_set("@#{name}", args)
              end
            end
          end
        end
      end

      # experimental
      def reload(name)
        plugin = @registered_plugins[name.to_sym]
        if plugin and plugin.file
          load plugin.file
        else
          Log.warn "can't reload #{plugin.inspect}"
        end
      end

      def reset!
        @registered_plugins = {}
        @event_handlers = Hash.new { |h, k| h[k] = [] }
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

          if method =~ /^on_(.+)/
            @event_handlers[$1.to_sym] << plugin
            commands << $1 if method =~ /^on_cmd_(.+)/
          end
        end

        file = caller[0].split(":").first

        plugin.instance_eval do
           name(name)
           commands(commands)
           file(file) if File.exist?(file)
         end

        @registered_plugins[name.to_sym] = plugin
      end

      def run_event(event)
        event_type = event.command? ? "cmd_#{event.command}".to_sym : event.type

        @event_handlers[event_type].each do |handler|
          break if(event.stop?)
          handler.send "on_#{event_type}", event
        end
      end

    end # class << self

    def to_s
      "#<FBSDBot::Plugin: #{@name}, #{@version}>"
    end

    reset!
    def_field :name, :author, :version, :commands, :file
  end

end
