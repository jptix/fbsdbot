require 'net/http'


class Web < PluginBase

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

   def cmd_wp(event, line)

      if !line or line.empty?
         reply(event, 'USAGE: define <search string>')
         return
      end

      Net::HTTP.start('www.google.com') do |http|
         search = line.gsub(/[^a-zA-Z0-9_\.\-]/) { |s| sprintf('%%%02x', s[0]) }
         re = http.get("/search?ie=utf8&oe=utf8&q=site%3Awikipedia.org+#{search}", { 'User-Agent' => 'FBSDBot' })
         if re.code == '200'
            if re.body =~ /<td class="j">(.+?)<br><span class=a>(.+?) -/
               desc, link = $1, $2
               desc = desc.gsub('<b>', "\x02").gsub('</b>', "\x0f").gsub(/<.+?>/, '')
               link = link.gsub('<b>', "\x02").gsub('</b>', "\x0f").gsub(/<.+?>/, '')
               reply(event, desc + " ( " + link.gsub(%r[^(?!http://)], 'http://') + " )")
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

end
