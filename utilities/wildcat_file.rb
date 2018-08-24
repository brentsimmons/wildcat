# Contains the attributes, text, and text type of a file.
# Could be a page, post, or settings file.

require 'kramdown'
require_relative 'file_parser'
require_relative '../wildcat_constants'

class WildcatFile
  attr_reader :attributes
  attr_reader :text
  attr_reader :path

  TEXT_TYPE_MARKDOWN = 'markdown'.freeze
  TEXT_TYPE_HTML = 'html'.freeze
  TEXT_TYPE_UNKNOWN = 'unknown'.freeze

  def initialize(path)
    # if cached_file = @@cache[path] then return cached_file end

    @path = path
    @text_type = text_type_from_path(path)
    @attributes, @text = FileParser.attributes_and_text(path)
    @rendered_text = ''
    # @@cache[path] = self
  end

  def to_html
    @rendered_text = render_text if @rendered_text.empty?
    @rendered_text
  end

  private

    @@cache = {}

    def text_type_from_path(path)
      return TEXT_TYPE_MARKDOWN if path.end_with?(MARKDOWN_SUFFIX)
      return TEXT_TYPE_HTML if path.end_with?(HTML_SUFFIX)
      TEXT_TYPE_UNKNOWN
    end

    def render_text
      if @text_type == TEXT_TYPE_MARKDOWN
        Kramdown::Document.new(
          @text,
          input: :kramdown,
          remove_block_html_tags: false,
          transliterated_header_ids: true
        ).to_html
      else
        @text
      end
    end
end
