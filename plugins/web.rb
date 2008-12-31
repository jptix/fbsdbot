require 'net/http'
require 'cgi'


FBSDBot::Plugin.define("web") {
  author "jp_tix"
  version "0.0.2"
  commands %w{google calc wp}

  # =============
  # = Web class =
  # =============

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

    end # method google

    # def calc(line)
    # 
    #   if !line or line.empty?
    #     return 'USAGE: calc <expression>'
    #   end
    # 
    #   Net::HTTP.start('www.google.com') do |http|
    #     search = line.gsub(/[^a-zA-Z0-9_\.\-]/) { |s| sprintf('%%%02x', s[0]) }
    #     re = http.get("/search?ie=utf8&oe=utf8&q=#{search}", { 'User-Agent' => 'FBSDBot' })
    #     if re.code == '200'
    #       if re.body =~ /<b>#{Regex.escape(exp)} = (.+?)<\/b>/
    #         result = $1
    #         result = result.gsub('<b>', "\x02").gsub('</b>', "\x0f").gsub("&#215;","x").gsub("<sup>","^").gsub("</sup>", "").gsub(/<.+?>/, '')
    #         return CGI.unescapeHTML(result)
    #       else
    #         return "Not found."
    #       end
    #     else
    #       return "Google returned an error: #{re.code} #{re.message}"
    #     end
    #   end
    # 
    # end # method calc

    # def wp(line)
    # 
    #   if !line or line.empty?
    #     return 'USAGE: wp <search string>'
    #   end
    # 
    #   Net::HTTP.start('www.google.com') do |http|
    #     re = http.get("/search?ie=utf8&oe=utf8&q=site%3Awikipedia.org+#{CGI.escape(line.strip)}", { 'User-Agent' => 'FBSDBot' })
    #     if re.code == '200'
    #       if re.body =~ /<td class="j">(.+?)<br><span class=a>(.+?) -/
    #         desc, link = $1, $2
    #         desc = desc.gsub('<b>', "\x02").gsub('</b>', "\x0f").gsub(/<.+?>/, '')
    #         link = link.gsub('<b>', "\x02").gsub('</b>', "\x0f").gsub(/<.+?>/, '')
    #         return CGI.unescapeHTML("#{desc} ( #{link.gsub(%r[^(?!http://)], 'http://')} )")
    #       elsif re.body =~ /did not match any documents/
    #         return 'No definition found.'
    #       else
    #         return "Error parsing Google output."
    #       end
    #     else
    #       return "Google returned an error: #{re.code} #{re.message}"
    #     end
    #   end
    # 
    # end # method wp

  end # class Web

  @web = Web.new

  # ==================
  # = Action Hooks =
  # ==================

  def on_cmd_google(action)
    action.reply @web.google(action.message)
  end

  def on_cmd_calc(action)
    action.reply @web.calc(action.message)
  end

  def on_cmd_wp(action)
    action.reply @web.wp(action.message)
  end

}
