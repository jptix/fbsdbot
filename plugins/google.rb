require 'net/http'


class Google < PluginBase
     
   def cmd_test(event, line)
      reply "Yes, it works!"
   end
   
   def cmd_google(event, line)

     # Argument checks.
     if !line or line.empty?
       reply(event, 'USAGE: google <search string>')
       return
     end

       Net::HTTP.start('www.google.com') do |http|
         search = line.gsub(/[^a-zA-Z0-9_\.\-]/) { |s| sprintf('%%%02x', s[0]) }
         re = http.get("/search?ie=utf8&oe=utf8&q=#{search}", { 'User-Agent' => 'FBSDBot' })
         if re.code == '200'
           if re.body =~ /<a href="([^"]+)" class=l>(.+?)<\/a>/
             link = $1
             desc = $2.gsub('<b>', "\x02").gsub('</b>', "\x0f")
             reply(event, "#{link} (#{desc})")
           elsif re.body =~ /did not match any documents/
             reply(event, 'Nothing found.')
           else
             reply(event, "Error parsing Google output.")
           end
         else
           reply(event, "Google returned an error: #{re.code} #{re.message}")
         end
       end
   end
   
end
