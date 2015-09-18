# Title: Include Code Tag for Jekyll
# Author: Brandon Mathis http://brandonmathis.com
# Description: Import files on your filesystem into any blog post as embedded code snippets with syntax highlighting and a download link.
# Configuration: You can set default import path in _config.yml (defaults to code_dir: downloads/code)
#
# Syntax {% include_code path/to/file %}
#
# Example 1:
# {% include_code javascripts/test.js %}
#
# This will import test.js from source/downloads/code/javascripts/test.js
# and output the contents in a syntax highlighted code block inside a figure,
# with a figcaption listing the file name and download link
#
# Example 2:
# You can also include an optional title for the <figcaption>
#
# {% include_code Example 2 javascripts/test.js %}
#
# will output a figcaption with the title: Example 2 (test.js)
#

require './plugins/pygments_code'
require './plugins/raw'
require 'pathname'

module Jekyll

  class IncludeCodeTag < Liquid::Tag
    def initialize(tag_name, markup, tokens)
      @title = nil
      @file = nil
      @startline = nil
      @endline = nil
      if markup.strip =~ /\s*lang:(\S+)/i
        @filetype = $1
        markup = markup.strip.sub(/lang:\S+/i,'')
      end
      if markup.strip =~ /\s*range:(\d+)-(\d+)/i
        @startline = $1
        @endline = $2
        markup = markup.strip.sub(/range:(\d+)-(\d+)/i,'')
      end
      if markup.strip =~ /(.*)?(\s+|^)(\/*\S+)/i
        @file = $3
      end
      if markup.strip =~ /\s*"(.+)"/i
        @title = $1 || nil
        markup = markup.strip.sub(/"(.+)"/i,'')
      end
      super
    end

    def render(context)
      code_dir = (context.registers[:site].config['code_dir'].sub(/^\//,'') || 'downloads/code')
      code_path = (Pathname.new(context.registers[:site].source) + code_dir).expand_path
      file = code_path + @file

      if File.symlink?(code_path)
        return "Code directory '#{code_path}' cannot be a symlink"
      end

      unless file.file?
        return "File #{file} could not be found"
      end

      Dir.chdir(code_path) do
        code = file.read
        if @startline != nil 
          code = code.lines.to_a[(@startline[0].to_i-1)..(@endline[0].to_i-1)].join
        end
        @filetype = file.extname.sub('.','') if @filetype.nil?
        title = @title ? "#{@title} (#{file.basename})" : file.basename
        url = "/#{code_dir}/#{@file}"
        source = "<figure class='code'><figcaption><span>#{title}</span> <a href='#{url}'>download</a></figcaption>\n"
        source += "#{HighlightCode::highlight(code, @filetype)}</figure>"
        TemplateWrapper::safe_wrap(source)
      end
    end
  end

end

Liquid::Template.register_tag('include_code', Jekyll::IncludeCodeTag)
