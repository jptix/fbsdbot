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


end
