# Title: Simple Image tag for Jekyll
# Authors: Brandon Mathis http://brandonmathis.com
#          Felix Schäfer, Frederic Hemberger
# Description: Easily output images with optional class names, width, height, title and alt attributes
#
# Syntax {% iframe [class name(s)] [http[s]:/]/path/to/image [width [height]] [title text | "title text" ["alt text"]] %}
#
# Examples:
# {% iframe /images/ninja.png Ninja Attack! %}
# {% iframe left half http://site.com/images/ninja.png Ninja Attack! %}
# {% iframe left half http://site.com/images/ninja.png 150 150 "Ninja Attack!" "Ninja in attack posture" %}
#
# Output:
# <iframe src="/images/ninja.png">
# <iframe class="left half" src="http://site.com/images/ninja.png" title="Ninja Attack!" alt="Ninja Attack!">
# <iframe class="left half" src="http://site.com/images/ninja.png" width="150" height="150" title="Ninja Attack!" alt="Ninja in attack posture">
#

module Jekyll

  class IframeTag < Liquid::Tag
    @iframe = nil

    def initialize(tag_name, markup, tokens)
      attributes = ['class', 'src', 'width', 'height', 'title']

      if markup =~ /(?<class>\S.*\s+)?(?<src>(?:https?:\/\/|\/|\S+\/)\S+)(?:\s+(?<width>\d+))?(?:\s+(?<height>\d+))?(?<title>\s+.+)?/i
        @iframe = attributes.reduce({}) { |iframe, attr| iframe[attr] = $~[attr].strip if $~[attr]; iframe }
        if /(?:"|')(?<title>[^"']+)?(?:"|')\s+(?:"|')(?<alt>[^"']+)?(?:"|')/ =~ @iframe['title']
          @iframe['title']  = title
          @iframe['alt']    = alt
        else
          @iframe['alt']    = @iframe['title'].gsub!(/"/, '&#34;') if @iframe['title']
        end
        @iframe['class'].gsub!(/"/, '') if @iframe['class']
      end
      super
    end

    def render(context)
      if @iframe
        "<iframe #{@iframe.collect {|k,v| "#{k}=\"#{v}\"" if v}.join(" ")}>"
      else
        "Error processing input, expected syntax: {% iframe [class name(s)] [http[s]:/]/path/to/image [width [height]] [title text | \"title text\" [\"alt text\"]] %}"
      end
    end
  end
end

Liquid::Template.register_tag('iframe', Jekyll::IframeTag)
