
# =====================
# = RSS Reader Plugin =
# =====================


FBSDBot::Plugin.define "rss" do
   author "jp_tix"
   version "0.0.3"
   commands %w{subscribe unsubscribe rssfilter rssrefresh rsslist}

   require "net/http"
   require 'rss'
   require "uri"
   require 'cgi'
   require "yaml"
   require 'rexml/document'

   class SimpleRSSParser
      RSS      = Struct.new("RSS", :channel, :items)
      Item     = Struct.new("Item", :title, :link, :description, :guid, :author, :pubDate)
      Channel  = Struct.new("Channel", :title, :link, :description)
      Guid     = Struct.new("Guid", :content)

      def SimpleRSSParser.parse(src)
         @items   = []
         @xml     = REXML::Document.new(src)
         @channel = Channel.new(@xml.root.elements['channel/title'].text, @xml.root.elements['channel/link'].text, @xml.root.elements['channel/description'].text)

         @xml.elements.each('//item') do |item|
            title       = item.elements['title'] ? item.elements['title'].text : nil
            link        = item.elements['link'] ? item.elements['link'].text : nil
            description = item.elements['description'] ? item.elements['description'].text : nil
            guid        = item.elements['guid'] ? item.elements['guid'].text : nil
            author      = item.elements['dc:creator'] ? item.elements['dc:creator'].text : nil
            pubDate     = (item.elements['dc:date'] ? item.elements['dc:date'].text : nil) || (item.elements['pubDate'] ? item.elements['pubDate'].text : nil)
            guid = Guid.new(guid) unless guid.nil?
            item = Item.new(title, link, description, guid, author, pubDate)
            @items << item
         end
         return RSS.new(@channel, @items)
      end

   end


   class RSSReader
      attr_accessor :refresh, :feeds

      class Feed
         attr_accessor :unread, :filters
         attr_reader :url

         class Item
            attr_accessor :read


            def initialize(channel, item)
               @channel = channel
               @item = item
               @read = false
               if @item.pubDate.nil?
                  @sha1 = Digest::SHA1.hexdigest(@item.link + @item.description.to_s)
               elsif @item.link.nil?
                  @sha1 = Digest::SHA1.hexdigest(@item.description.to_s + @item.pubDate.to_s)
               else
                  @sha1 = Digest::SHA1.hexdigest(@item.link + @item.pubDate.to_s)
               end
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

               body   = @item.description.to_s.gsub(/<.*?>/, ' ')
               body   = CGI::unescapeHTML(body)
               body   = body.gsub(/\s+/, ' ').gsub(/\A\s+|\s+\z/, '')
               body   = body.sub(/(.{0,#{length}})(\s.+)?$/) { $1 + ($2.nil? ? '' : '…')}

               prefix + body + suffix
            end

            def guid
               if @sha1.nil? or @sha1.empty?
                  if @item.respond_to? :guid
                     @item.guid.nil? ? @item.link : @item.guid.content
                  else
                     @item.link
                  end
               else
                  @sha1
               end

            end

         end # end class Item

         # init method for new feed
         def initialize(url, last_checked = '', read_guids = [], filters = [])
            puts "Adding feed #{url}"
            @url = URI.parse(url)
            @title = ''
            @last_checked = last_checked
            @unread = []
            @filters = filters
            read_guids.nil? ? @read_guids = [] : @read_guids = read_guids
            @first_check = true
            check
         end

         def check
            begin
               @last_checked = Time.now
               # DONE: Need to fall back on our own parser for RSS 0.90 feeds.
               # The parser should return objects similar to the built-in RSS library
               # so the rest of the plugin can work as is. Basically an array of 'item' objects
               # that has accessors for title, link, description etc. will do.
               begin
                  rss = RSS::Parser.parse(open(@url.to_s))
               rescue
                  puts "Using SimpleRSSParser for #{@url} (#{$!.message})" if @first_check
                  rss = SimpleRSSParser.parse(open(@url.to_s))
               end
               @title = rss.channel.title
               items = rss.items.map { |item| Item.new(rss.channel, item) }
               items.delete_if { |item| @read_guids.include?(item.guid) }
               @read_guids += items.map { |item| item.guid }
               items = items.select { |item| @filters.any? { |f| f =~ item.summary } } unless @filters.empty? 
               @unread = items
               @first_check = false
            rescue # trying this to rescue "Operation timed out - connect(2)"
               puts "#{$!.message}\n#{$!.backtrace.join("\n")}"
               retry
            end
         end

         def title
            @title.nil? ? @url.to_s : @title
         end

         def save
            {'url' => @url.to_s, 'last_checked'  => @last_checked, 'read_guids' => @read_guids, 'filters' => @filters}
         end

      end # end class Feed

      # init method for RSSReader class
      def initialize
         @feeds = []
      end

      def subscribe(url)
         begin
            if @feeds.any? { |feed| feed.url.to_s == url }
               return "I'm already subscribed to #{url}"
            elsif @feeds.nil?
               @feeds = [Feed.new(url)]
            else
               @feeds << Feed.new(url)
            end
            return "OK, subscribed to feed"
         rescue
            return $!.message
         end
      end

      def add_filter_for_feed(action, url_or_regexp, filter)
         feeds = @feeds.select { |f| f.url.to_s == url_or_regexp or f.url.to_s =~ Regexp.new(url_or_regexp, true) }
         if feeds.empty?
            action.reply "No matching feeds found."
            return
         end
         regexp = Regexp.new(filter, true)
         urls = {:saved => [], :added => []}
         feeds.each do |f|
            url = f.url.to_s.gsub("http://", '')
            if f.filters.include?(regexp)
               urls[:saved] << url
            else
               f.filters << regexp
               urls[:added] << url
            end
         end
         action.reply "Added filter #{regexp} to #{urls[:added].join(" %r|%n ")}" unless urls[:added].empty?
         action.reply "Filter already saved for #{urls[:saved].join(" %r|%n ")}" unless urls[:saved].empty?
      end

      def del_filter_for_feed(action, url_or_regexp, filter)
         feeds = @feeds.select { |f| f.url.to_s == url_or_regexp or f.url.to_s =~ Regexp.new(url_or_regexp, true) }
         if feeds.empty?
            action.reply "No matching feeds found."
            return
         end

         urls = {:deleted => [], :not_found => [], :result => nil}
         feeds.each do |f|
            url = f.url.to_s.gsub("http://", '')
            if filter == "*"
               f.filters = []
               result = "all filters"
            else
               result = filter if f.filters.reject! { |f| f.to_s == filter or f == Regexp.new(filter, true) }
            end
            if result
               urls[:deleted] << url
               urls[:result] = result
            else
               urls[:not_found] << url
            end
         end
         action.reply "Deleted #{urls[:result]} from #{urls[:deleted].join(" %r|%n ")}" unless urls[:deleted].empty?
         action.reply "No matching filters found for #{urls[:not_found].join(" %r|%n ")}" unless urls[:not_found].empty?

      end

      def list_filters_for_feed(action, url_or_regexp)
         if url_or_regexp
            feeds = @feeds.select { |f| f.url.to_s == url_or_regexp or f.url.to_s =~ Regexp.new(url_or_regexp, true) }
         else
            feeds = @feeds
         end
         if feeds.empty?
            action.reply "No matching feeds found."
            return
         end
         feeds.each do |f|
            url = f.url.to_s.gsub("http://", '')
            if f.filters.empty?
               action.reply "No active filtering for #{url}"
            else
               action.reply "Active filters for #{url}: #{f.filters.join(' ')}"
            end
         end
      end

      def unsubscribe(url_or_regexp)
         old_feeds = @feeds.dup
         @feeds.reject! do |feed|
            feed = feed.url.to_s
            true if feed == url_or_regexp or feed =~ Regexp.new(url_or_regexp, true)
         end
         return old_feeds - @feeds
      end

      def load(filename)
         if File.exist?(filename)
            @feeds = open(filename) { |io| yml = YAML.load(io); yml.map { |feed| Feed.new(feed['url'], feed['last_checked'], feed['read_guids'], feed['filters']) } if yml }
         else
            @feeds = []
         end
      end

      def save(filename)
         open(filename, "w") { |io| YAML.dump(@feeds.map { |feed| feed.save }, io)  } unless @feeds.nil?
      end

      def run(action, filename = 'rss.yaml', refresh = 30*60)
         @action = action
         @refresh = refresh
         Thread.new do
            begin
               load(filename)

               loop do
                  puts "Checking feeds @ #{Time.now}"
                  feed_refresh = @refresh / @feeds.size if @feeds.size > 0
                  @feeds.each do |feed|
                     puts "===> #{feed.url} (@ #{Time.now})"
                     feed.check
                     feed.unread.each do |item|
                        puts "=======> #{item.title} "
                        action.send_message(item.summary, action.channel)
                        item.read = true
                     end
                     sleep(feed_refresh)
                  end unless @feeds.nil?
                  puts "Done checking feeds."
                  save(filename)
                  sleep(@refresh) unless @feeds.size > 0
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
   @filename = $botdir + 'rss.yaml'

   def on_join(action)
      return if @started
      @action = action
      @reader.run(@action, @filename, ($config['rss-refresh'] || 30*60))
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
      if result.empty?
         action.reply "I'm not subscribed to #{action.message}"
      else
         action.reply "Removed subscription: " + result.map { |feed| feed.url.to_s }.join("; ")
      end
   end

   def on_msg_rssrefresh(action)
      if action.message =~ /^\d+$/
         period = action.message.to_i
         @reader.save(@filename)
         @msg = "NB: RSS refresh period was changed from #{@reader.refresh} to #{period} seconds." unless period == $config['rss-refresh']
         @reader.refresh = period
         action.reply "RSS refresh period set to #{period} seconds."
      else
         action.reply "Please provide a refresh period in seconds."
      end
   end

   def on_msg_rsslist(action)
      type = (action.message == 'urls' ? :url : :title)
      if @reader.feeds.size > 0
         plural = @reader.feeds.size > 1
         action.reply "I'm currently subscribed to #{plural ? 'these' : 'this'} feed#{ plural ? 's' : ''}: " + @reader.feeds.map { |f| f.send(type).to_s + (f.filters.size > 0 ? ' (w/filtering)' : '') }.join(" %r|%n ")
      else
         action.reply "I'm not subscribed to any feeds."
      end
   end

   def on_msg_rssfilter(action)
      cmd = action.message.split(/\"(.+?)\"|\s/).reject { |e| e.empty? }

      case cmd.shift
      when "add"
         if cmd.size != 2
            action.reply "usage: rssfilter add <url or regexp> <filter>"
         else
            @reader.add_filter_for_feed(action, cmd[0], cmd[1])
         end
      when "del"
         if cmd.size != 2
            action.reply "usage: rssfilter del <url or regexp> <filter>"
         else
            @reader.del_filter_for_feed(action, cmd[0], cmd[1])
         end
      when "list"
         @reader.list_filters_for_feed(action, cmd[0])
      end


   end

   def on_shutdown
      @reader.save(@filename) unless @reader.feeds.empty?
      puts @msg unless @msg.nil?
   end


end
