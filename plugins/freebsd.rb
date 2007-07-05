require 'net/http'
require 'cgi'


# =====================================
# = Plugin for FreeBSD-specific stuff =
# =====================================
class Freebsd < PluginBase


   # display output from the whatis shell command
   def cmd_whatis(event, line)
      if !line or line.empty?
         reply(event, 'USAGE: whatis <search string>')
      else
         reply(event, %x{whatis "#{line}"})
      end
   end

   # command to look up man pages (name + synopsis)
   def cmd_man(event, line)

      if !line or line.empty?
         reply(event, 'USAGE: man <search string>')
         return
      end

      line = line.strip
      man_html = %x{man '#{e_sh(line)}' | groff -man -Thtml 2>/dev/null}
      if man_html =~ /<p.*>NAME(.+?)<\/p>.+?<p.*>SYNOPSIS(.+?)<\/p>/m
         name, synop = $1, $2
         name = name.gsub('<b>', "\x02").gsub('</b>', "\x0f").gsub(/<.+?>/, '').gsub("\n", '').strip
         synop = synop.gsub('<b>', "\x02").gsub('</b>', "\x0f").gsub(/<.+?>/, '').strip
         cmd = name =~ /^(.+) --?/ ? $1 : line
         link = "http://www.freebsd.org/cgi/man.cgi?query=#{CGI.escape(line)}"
         reply event, "#{name} ( #{link} )".decode_entities
         synop.gsub(/\n|\t/, ' ').gsub(cmd, "\n" + cmd).split("\n").each_with_index do |line, index|
            reply(event, line.decode_entities) unless line.empty? or index > 3
         end
      else
         reply event, "No manual entry for #{line}"
      end
   end
   
   def cmd_ports(event, line)
     
     if !line or line.empty?
        reply(event, 'USAGE: ports <search string>')
        return
     end
     
     Net::HTTP.start('www.freshports.org') do |http|
        re = http.get("/search.php?query=#{CGI.escape(line.strip)}&search=go&num=10&stype=name&method=match&deleted=excludedeleted&start=1&casesensitivity=caseinsensitive", { 'User-Agent' => 'FBSDBot' })
        if re.code == '200'
           ports = []
           re.body.scan(/<BIG><B>(.+?)<\/B>.+?<code class="code">(.+?)<\/code>/m) { |match| ports << match  }
           if ports.empty?
              reply event, 'No ports found.'
           else
              ports.each_with_index do |port, index|
                 if port[0] =~ /<a href="(.+?)">(.+?)<\/a>(.+)/
                    link, name, version = $1, $2, $3
                    reply event, "\x02#{name.strip}\x0f - #{version.strip} => #{port[1]}"
                    reply event, "     ( #{'http://www.freshports.org' + link} )"
                 else
                   reply event, "Parse error."
                 end if index < 3
              end
           end
        else
           reply event, "Freshports.org returned an error: #{re.code} #{re.message}"
        end
     end
    
   end


end
