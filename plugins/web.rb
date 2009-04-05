# encoding: utf-8
require 'net/http'
require 'cgi'


FBSDBot::Plugin.define("web") {
  author "jp_tix"
  version "0.0.2"

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
            desc = normalize($2)
            return "#{link} (#{desc})"
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

    def calc(line)

      if !line or line.empty?
        return 'USAGE: calc <expression>'
      end

      Net::HTTP.start('www.google.com') do |http|
        search = line.gsub(/[^a-zA-Z0-9_\.\-]/) { |s| sprintf('%%%02x', s[0]) }
        re = http.get("/search?ie=utf8&oe=utf8&q=#{search}", { 'User-Agent' => 'FBSDBot' })
        if re.code == '200'
          if re.body =~ /<div id=res.+?<b>(.+?)<\/b>/
            result = normalize($1)
            return CGI.unescapeHTML(result)
          else
            return "Not found."
          end
        else
          return "Google returned an error: #{re.code} #{re.message}"
        end
      end

    end # method calc

    def wp(line)

      if !line or line.empty?
        return 'USAGE: wp <search string>'
      end

      Net::HTTP.start('www.google.com') do |http|
        re = http.get("/search?ie=utf8&oe=utf8&q=site%3Awikipedia.org+#{CGI.escape(line.strip)}", { 'User-Agent' => 'FBSDBot' })
        if re.code == '200'
          if re.body =~ /<div class="s">(.+?)<cite>(.+?)\s/
            desc, link = $1, $2
            desc = normalize(desc)
            link = normalize(link).gsub(%r[^(?!http://)], 'http://')
            return "#{desc} ( #{link} )"
          elsif re.body =~ /did not match any documents/
            return 'No definition found.'
          else
            return "Error parsing Google output."
          end
        else
          return "Google returned an error: #{re.code} #{re.message}"
        end
      end

    end # method wp

    def normalize(string)
      # TODO: find better way to do this + write specs
      string = string.gsub(/<(b|em)>/, "\x02").
                      gsub(/<\/(b|em)>/, "\x0f").
                      gsub("&#215;","x").
                      gsub("<sup>","^").
                      gsub("</sup>", "").
                      gsub(/<.+?>/, '')

      CGI.unescapeHTML(string)
    end

  end # class Web

  @web = Web.new

  # ==================
  # = Action Hooks =
  # ==================

  def on_cmd_google(action)
    action.reply @web.google(action.message.sub(/^!google /, ''))
  end

  def on_cmd_calc(action)
    action.reply @web.calc(action.message.sub(/^!calc /, ''))
  end

  def on_cmd_wp(action)
    action.reply @web.wp(action.message.sub(/^!wp /, ''))
  end

}
