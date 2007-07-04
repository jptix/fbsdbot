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
  
  
  # command to look up man pages on FreeBSD.org
  # too slow perhaps, should use local man pages if running on a FreeBSD box
  def cmd_man(event, line)

      if !line or line.empty?
         reply(event, 'USAGE: man <search string>')
         return
      end

    Net::HTTP.start('www.freebsd.org') do |http|
       search = CGI.escape(line.strip)
       re = http.get("/cgi/man.cgi?query=#{search}", { 'User-Agent' => 'FBSDBot' })
       if re.code == '200'
         if re.body =~ /<B>NAME<\/B>(.+?)<a.+?<B>SYNOPSIS<\/B>(.+?)<a/m
           name, synop = $1, $2
           name = name.gsub('<b>', "\x02").gsub('</b>', "\x0f").gsub(/<.+?>/, '').gsub("\n", '').strip
           synop = synop.gsub('<b>', "\x02").gsub('</b>', "\x0f").gsub(/<.+?>/, '').strip
           cmd = name.match(/^(.+) --/)[1].strip
           link = "http://www.freebsd.org/cgi/man.cgi?query=#{search}"
           reply event, "#{name} ( #{link} )".decode_entities
           synop.gsub(/\n|\t/, ' ').gsub(cmd, "\n" + cmd).split("\n").each_with_index do |line, index| 
             line = line.strip
             reply(event, line) unless line.empty? or index > 3
           end
          elsif re.body =~ /Sorry, no data found for/
            reply event, "No match."
          else
            reply event, "Error parsing output."  
          end
       else
          reply(event, "FreeBSD.org returned an error: #{re.code} #{re.message}")
       end
    end
  end
  
  
end