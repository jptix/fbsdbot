require 'net/http'
require 'cgi'


FBSDBot::Plugin.define("web") {
   author "jp_tix"
   version "0.0.1"

   class Web
      def google(line)
         if !line or line.empty?
            return 'USAGE: google <search string>'
         end

         Net::HTTP.start('www.google.com') do |http|
            re = http.get("/search?ie=utf8&oe=utf8&q=#{CGI.escape(line.strip)}", { 'User-Agent' => 'FBSDBot' })
            if re.code == '200'
               if re.body =~ /<a href="([^"]+)" class=l>(.+?)<\/a>/
                  link = $1
                  desc = $2.gsub('<b>', "\x02").gsub('</b>', "\x0f")
                  return CGI.unescapeHTML("#{link} (#{desc})")
               elsif re.body =~ /did not match any documents/
                  return 'Nothing found.'
               else
                  return "Error parsing Google output."
               end
            else
               return "Google returned an error: #{re.code} #{re.message}"
            end
         end

      end
   end

   @web = Web.new

   # ==================
   # = Plugin Methods =
   # ==================

   def on_pubmsg_google(action) # becomes a singleton method
      line = action.message
      action.reply @web.google(line)

   end
}
