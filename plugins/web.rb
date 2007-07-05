require 'net/http'
require 'cgi'

# ========================================
# = Plugin for various web functionality =
# ========================================
class Web < PluginBase

   def cmd_google(event, line)

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
               reply(event, CGI.unescapeHTML("#{link} (#{desc})"))
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

   def cmd_wp(event, line)

      if !line or line.empty?
         reply(event, 'USAGE: wp <search string>')
         return
      end

      Net::HTTP.start('www.google.com') do |http|
         re = http.get("/search?ie=utf8&oe=utf8&q=site%3Awikipedia.org+#{CGI.escape(line.strip)}", { 'User-Agent' => 'FBSDBot' })
         if re.code == '200'
            if re.body =~ /<td class="j">(.+?)<br><span class=a>(.+?) -/
               desc, link = $1, $2
               desc = desc.gsub('<b>', "\x02").gsub('</b>', "\x0f").gsub(/<.+?>/, '')
               link = link.gsub('<b>', "\x02").gsub('</b>', "\x0f").gsub(/<.+?>/, '')
               reply(event, CGI.unescapeHTML("#{desc} ( #{link.gsub(%r[^(?!http://)], 'http://')} )"))
            elsif re.body =~ /did not match any documents/
               reply(event, 'No definition found.')
            else
               reply(event, "Error parsing Google output.")
            end
         else
            reply(event, "Google returned an error: #{re.code} #{re.message}")
         end
      end

   end
   
   def cmd_calc(event, line)

     if !line or line.empty?
        reply(event, 'USAGE: calc <expression>')
        return
     end

     Net::HTTP.start('www.google.com') do |http|
        search = line.gsub(/[^a-zA-Z0-9_\.\-]/) { |s| sprintf('%%%02x', s[0]) }
        re = http.get("/search?ie=utf8&oe=utf8&q=#{search}", { 'User-Agent' => 'FBSDBot' })
        if re.code == '200'
           if re.body =~ /<div id=res>.+?<b>(.+?)<\/b>/
              result = $1
              result = result.gsub('<b>', "\x02").gsub('</b>', "\x0f").gsub("&#215;","x").gsub("<sup>","^").gsub("</sup>", "").gsub(/<.+?>/, '')
              reply(event, CGI.unescapeHTML(result))
           else
              reply(event, "Not found.")
           end
        else
           reply(event, "Google returned an error: #{re.code} #{re.message}")
        end
     end
      
   end

end
