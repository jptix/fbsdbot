module FBSDBot
  class Action

    attr_reader :auth, :nick, :channel, :message, :hostmask, :type, :command

    def initialize(bot, auth, event, command = nil)
      @event    = event
      @bot      = bot
      @auth     = auth
      @nick     = nil
      @channel  = nil
      @message  = nil
      @hostmask = nil
      @command  = nil
      @type     = nil

      case event.event_type.to_sym
      when :privmsg

        #STDERR.puts event.inspect

        @nick = event.from
        @message = event.message
        unless event.message.nil?
          if command
            @message = event.message.sub(/^!?#{command}/, '').strip
            @command = command
          else
            @message = event.message
            @command = nil
          end
        end
        @hostmask = event.hostmask

        # private / public?
        if event.channel == bot.nick
          @type       = :privmsg
          @respond_to = @nick
        else
          @type       = :pubmsg
          @channel    = event.channel
          @respond_to = @channel
        end

        # ctcp also gets handled as privmsg, so we have to override the type here
        if event.message[0] == 001
          if event.message[event.message.size - 1] == 001
            @message = event.message[1, event.message.size - 2].downcase
          else
            @message = event.message[1, event.message.size - 1].downcase
          end
          @type = :ctcp
          @respond_to = @nick
        end
      when :join
        @nick        = event.from
        @hostmask    = event.hostmask
        @channel     = event.channel
        @message     = nil
        @type        = :join
        @respond_to  = @channel
      when :part
        @nick         = event.from
        @hostmask     = event.stats[1]
        @channel      = event.channel
        @message      = event.message
        @type         = :part
        @respond_to   = @channel
      when :quit
        @nick         = event.from
        @hostmask     = event.stats[1]
        @channel      = event.channel
        @message      = event.message
        @type         = :quit
        @respond_to   = @channel
      end
    end

    def auth?
      self.auth.is_authenticated?(self)
    end

    def reply(msg)
      msg = FBSDBot::format_string(msg)
      case @type.to_sym
      when :pubmsg
        @bot.send_message(@respond_to, "#{@nick}, #{msg}")
      when :privmsg
        @bot.send_message(@respond_to, msg)
      when :ctcp
        @bot.send_notice(@respond_to, 001.chr + "#{@message.upcase}: #{msg}" + 001.chr)
      end
    end

    def send_message(msg, to = @respond_to)
      @bot.send_message(to, FBSDBot::format_string(msg))
    end

    def op(channel = @respond_to)
      @bot.op(channel.nil? ? @channel : channel,@nick)
    end

    def join(channel = @respond_to)
      @bot.join(channel)
    end

    def notice(message, to = @respond_to)
      @bot.send_notice(to, message)
    end

    def syntax(msg)
      return reply("Syntax: #{@command} #{msg}") unless @command.nil?
      reply("Syntax: #{msg}")
    end

  end
end