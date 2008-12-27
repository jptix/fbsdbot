module FBSDBot

  class Plugin
    @registered_plugins = {}

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
        p = new
        p.instance_eval(&block)
        p.instance_eval { name(name) }
        Plugin.registered_plugins[name.to_sym] = p
      end

      def find_plugins(event)
        found = false
        @registered_plugins.each do |name,plugin|
          case(event)

          when PrivateMessageEvent
            if event.message =~ /^!(\S+)/ && plugin.respond_to?("on_msg_#{$1}")
              plugin.send("on_msg_#{$1}", event)
            elsif plugin.respond_to?(:on_msg)
              plugin.send(:on_msg, event)
            end

          when CTCPVersionEvent
            Log.debug("Handling version event", event)
            plugin.send(:on_ctcp_version, event) if plugin.respond_to?(:on_ctcp_version)
          else
            Log.debug("find_plugins: no plugins respond", event)
          end
        end

        return found
      end

    end # class << self

    def to_s
      "#<FBSDBot::Plugin: #{@name}, #{@version}>"
    end

    def_field :name, :author, :version, :commands
  end

end
