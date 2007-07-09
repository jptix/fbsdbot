
# =====================
# = RSS Reader Plugin =
# =====================


FBSDBot::Plugin.define "rss" do
   author "jp_tix"
   version "0.0.2"
   commands %w{subscribe unsubscribe}

   require "net/http"
   require 'rss'
   require "uri"
   require 'cgi'
   require "yaml"


   class RSSReader
      class Feed
         attr_accessor :unread
         attr_reader :url

         class Item
            attr_accessor :read


            def initialize(channel, item)
               @channel = channel
               @item = item
               @read = false
            end

            def read?
               @read
            end

            def title
               @item.title
            end

            def summary(limit = 420)
               prefix = "%B#{@channel.title}%n %y#{@item.title}%n: "
               suffix = @item.link ? "%g — #{@item.link}" : ''
               length = limit - prefix.length - suffix.length

               body   = @item.description.gsub(/<.*?>/, ' ')
               body   = CGI::unescapeHTML(body)
               body   = body.gsub(/\s+/, ' ').gsub(/\A\s+|\s+\z/, '')
               body   = body.sub(/(.{0,#{length}})(\s.+)?$/) { $1 + ($2.nil? ? '' : '…')}

               prefix + body + suffix
            end

            def guid
               if @item.respond_to? :guid
                  @item.guid.nil? ? @item.link : @item.guid.content
               else
                  @item.link
               end
            end

         end # end class Item

         # init method for new feed
         def initialize(url, last_checked = '', read_guids = [])
            puts "Adding feed #{url}"
            @url = URI.parse(url)
            @last_checked = last_checked
            @unread = []
            @read_guids = read_guids
            @first_check = true
            check
         end

         def check
            @last_checked = Time.now
            path = @url.path.empty? ? "/" : @url.path
            # FIXME: Need to fall back on our own parser for RSS 0.90 feeds.
            # The parser should return objects similar to the built-in RSS library
            # so the rest of the plugin can work as is. Basically an array of 'item' objects 
            # that has accessors for title, link, description etc. will do. 
            rss = RSS::Parser.parse(open(@url.to_s), false)
            items = rss.items.map { |item| Item.new(rss.channel, item) }
            items.delete_if { |item| @read_guids.include?(item.guid) }
            @read_guids += items.map { |item| item.guid }
            unless @first_check
               @unread = items
            end
            @first_check = false
         end

         def save
            result = {'url' => @url.to_s, 'last_checked'  => @last_checked }
         end

      end # end class Feed

      def initialize
         @feeds = []
      end

      def subscribe(url)
         begin
            if @feeds.nil?
               @feeds = [Feed.new(url)]
            else
               @feeds << Feed.new(url)
            end
            return "OK, subscribed to feed"
         rescue
            return $!.message
         end
      end

      def unsubscribe(url)
         @feeds.reject! do |feed|
            feed = feed.url.to_s
            true if feed == url or feed =~ Regexp.new(url, true)
         end
      end

      def load(filename)
         if File.exist?(filename)
            @feeds = open(filename) { |io| yml = YAML.load(io); yml.map { |feed| Feed.new(feed['url'], feed['last_checked']) } if yml }
         else
            @feeds = []
         end
      end

      def save(filename)
         open(filename, "w") { |io| YAML.dump(@feeds.map { |feed| feed.save }, io)  } unless @feeds.nil?
      end

      def run(action, filename = 'rss.yaml', refresh = 30*60)
         @action = action
         thread = Thread.new do
            begin
               load(filename)

               loop do
                  puts "Checking feeds @ #{Time.now}"
                  @feeds.each do |feed|
                     puts "===> #{feed.url}"
                     feed.check
                     feed.unread.each do |item|
                        puts "=======> #{item.title} "
                        action.send_message(item.summary, action.channel)
                        item.read = true
                     end
                  end unless @feeds.nil?
                  puts "Done checking feeds."
                  save(filename)
                  sleep(refresh)
               end
            rescue
               puts $!.message
               puts $!.backtrace.join("\n")
            end
         end
      end


   end # class RSSReader

   @reader = RSSReader.new
   @started = false
   @filename = 'rss.yaml'

   def on_msg(action)
      return if @started
      @reader.run(action, @filename, ($config['rss-refresh'] || 30*60))
      @started = true
   end

   def on_msg_subscribe(action)
      if action.message =~ /^http:/
         result = @reader.subscribe(action.message)
         action.reply result
      else
         action.reply "Not a valid URL: #{action.message}"
      end
   end

   def on_msg_unsubscribe(action)
      result = @reader.unsubscribe(action.message)
      if result.nil?
         action.reply "I'm not subscribed to #{action.message}"
      else
         action.reply "No longer subscribed to: #{action.message}"
      end
   end

   def on_shutdown
      @reader.save(@filename)
   end


end
