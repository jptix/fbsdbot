# encoding: utf-8
FBSDBot::Plugin.define "PizzaHighlight" do

  author "Daniel Bond"
  version "0.0.3"

  @timings = {}

  def on_private_message(a)

    if a.message.match(/^#{a.worker.handler.nick}[:,]\s+(.+?) in (\d+)([mh])$/)
      what = $1
      time = ($3 == "m") ? $2.to_i * 60 : $2.to_i * 60^2
      
      a.reply "#{a.user.nick}: ok, ticket ##{a.object_id}"
      
      EventMachine::add_timer(time) {
        a.reply("#{a.user.nick}: it is time to #{what}! (ticket: ##{a.object_id})")
      }
    end
  end
end
