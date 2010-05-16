FBSDBot::Plugin.define(:console) do

  class ConsoleHandler < EM::Connection
    include EM::Protocols::LineText2
    
    attr_accessor :worker

    EOF = "\xFF"
    HELP = <<-HELP

      say <#channel> <msg>
      action <#channel> <msg>
      join <#channel>
      part <#channel>
      op <#channel> <user(,user)*>
      deop <#channel> <user(,user)*>

    HELP

    # TODO: kick/ban
    
    def receive_line(data)
      return unless worker
      
      case data
      when /^say (#\S+) (.*)$/
        worker.send_privmsg($2, $1) 
      when /^action (#\S+) (.*)$/
        worker.send_action($2, $1)
      when /^join (#\S+)$/
        worker.send_join($1)
      when /^part (#\S+)$/
        worker.send_part($1)
      when /^op (#\S+) (.*)$/
        worker.send_op($1, *$2.split(","))
      when /^deop (#\S+) (.*)$/
        worker.send_deop($1, *$2.split(","))
      when /^help/
        puts HELP
      when /^exit/
        EM.next_tick { puts "closing connection" }
        closing = true
        close_connection
      else
        puts "unknown command: #{data.inspect}"
      end

      prompt unless closing
    end

    def prompt
      print ">> "
    end
  end

  def on_cmd_console(event)
    return unless event.user.admin?
    EM.open_keyboard(ConsoleHandler) do |handler|
      handler.worker = event.worker
      handler.prompt
    end
  end
  
end
