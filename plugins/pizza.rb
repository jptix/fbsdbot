FBSDBot::Plugin.define "PizzaHighlight" do

  author "Daniel Bond"
  version "0.0.3"

  @timings = {}

  def on_private_message(a)

    if a.message.match(/^(.+?) in (\d+)([msh])$/)
      what = $1
      time = $2.to_i
      if $3 == "h"
        time = $2.to_i * 60 * 60
      elsif $3 == "m"
        time = $2.to_i * 60
      end
      
      EventMachine::add_timer(time) {
        a.reply("#{a.to}: #{what} is ready!")        
      }
    end
    
  end
end
