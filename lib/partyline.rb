# encoding: utf-8
FBSDBot::Plugin.define("partyline") {
  author "Daniel Bond"
  version "0.0.1"
  
  class PartyLineHandler < EventMachine::Connection
    
    def receive_data(data)
      reply data
    end
    
    def reply(what)
      send_data what
    end
    
    def connection_completed
      send_data "Hello, and welcome to partyline!\r\n"
    end
  end

  def on_ctcp_dcc(event)
    EventMachine::connect(event.ip, event.port, PartyLineHandler)
  end
}
