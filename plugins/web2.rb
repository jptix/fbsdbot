require 'net/http'
require 'cgi'

FBSDBot::Plugin.define("web") {
   author "jp_tix"
   version "0.0.1"
   
   def on_pubmsg_google(action) # becomes a singleton method
      line = action.message
     
      if !line or line.empty?
         action.reply 'USAGE: google <search string>'
         return
      end

      Net::HTTP.start('www.google.com') do |http|
         re = http.get("/search?ie=utf8&oe=utf8&q=#{CGI.escape(line.strip)}", { 'User-Agent' => 'FBSDBot' })
         if re.code == '200'
            if re.body =~ /<a href="([^"]+)" class=l>(.+?)<\/a>/
               link = $1
               desc = $2.gsub('<b>', "\x02").gsub('</b>', "\x0f")
               action.reply CGI.unescapeHTML("#{link} (#{desc})")
            elsif re.body =~ /did not match any documents/
               action.reply 'Nothing found.'
            else
               action.reply "Error parsing Google output."
            end
         else
            action.reply "Google returned an error: #{re.code} #{re.message}"
         end
      end

   end
}
