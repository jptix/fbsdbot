require 'net/http'
require 'cgi'

FBSDBot::Plugin.define("web") {
   author "jp_tix"
   version "0.0.1"

   def on_pubmsg_google(event,line) # becomes a singleton method


      if !line or line.empty?
         reply(event, 'USAGE: google <search string>')
         return
      end

      Net::HTTP.start('www.google.com') do |http|
         re = http.get("/search?ie=utf8&oe=utf8&q=#{CGI.escape(line.strip)}", { 'User-Agent' => 'FBSDBot' })
         if re.code == '200'
            if re.body =~ /<a href="([^"]+)" class=l>(.+?)<\/a>/
               link = $1
               desc = $2.gsub('<b>', "\x02").gsub('</b>', "\x0f")
               $bot.irc.send_message(event.channel, CGI.unescapeHTML("#{link} (#{desc})"))
            elsif re.body =~ /did not match any documents/
               $bot.irc.send_message(event.channel, 'Nothing found.')
            else
               $bot.irc.send_message(event.channel, "Error parsing Google output.")
            end
         else
            $bot.irc.send_message(event.channel, "Google returned an error: #{re.code} #{re.message}")
         end
      end

   end
}
