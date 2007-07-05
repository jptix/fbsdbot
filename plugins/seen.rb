
# ===============
# = Seen plugin =
# ===============


FBSDBot::Plugin.define("seen") {
   author "jp_tix"
   version "0.0.1"

   class Seen
      def initialize
        self.load
      end
    
      def log_event(nick, channel, event_type, message = '')
        # puts "Logged #{event_type.to_s} for #{nick}"  #    <-- DEBUG
        @seen[nick] = [event_type, message, Time.now, channel]
      end

      def seen_nick(action, nick)
        if nick == $bot.nick
          action.reply "I'm right here."
        elsif @seen.has_key?(nick)
            time = FBSDBot.seconds_to_s(Time.now.to_i - @seen[nick][2].to_i)
            info = @seen[nick]
            action.reply "#{nick} " + case info[0] 
            when :msg: "said '#{info[1]}' in #{info[3]}, #{time} ago."
            when :part: "left #{info[3]} #{time} ago" + (info[1].empty? ? '.' : ", saying: #{info[1]}.")
            when :join: "joined #{info[3]} #{time} ago."
            when :quit: "quit IRC #{time} ago" +  (info[1].empty? ? '.' : ", saying: #{info[1]}.")
            end
        else
          action.reply "Nope."
        end
        self.save
      end
      
      def save
        File.open("seen.yaml", "w") { |io| YAML.dump(@seen, io) }
      end
      
      def load
        begin
          @seen = YAML.load_file('seen.yaml')
        rescue
          @seen = {}
        end
      end
    
   end

   @logger = Seen.new

   def on_msg(action)
    @logger.log_event(action.nick, action.channel, :msg, action.message)
   end
   
   def on_part(action)
     @logger.log_event(action.nick, action.channel, :part, action.message)
   end
   
   def on_join(action)
    @logger.log_event(action.nick, action.channel, :join)
   end
   
   def on_quit(action)
     @logger.log_event(action.nick, nil, :quit, action.message)
   end
   
   def on_msg_seen(action)
     @logger.seen_nick(action, action.message)
   end




}