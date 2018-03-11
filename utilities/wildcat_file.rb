# Contains the attributes, text, and text type of a file.
# Could be a page, post, or settings file.

require 'rdiscount'
require_relative 'file_parser'
require_relative '../wildcat_constants'

class WildcatFile

  attr_reader :attributes
  attr_reader :text
  attr_reader :path

  TEXT_TYPE_MARKDOWN = 'markdown'
  TEXT_TYPE_HTML = 'html'
  TEXT_TYPE_UNKNOWN = 'unknown'

  def initialize(path)
    if cached_file = @@cache[path] then return cached_file end

    @path = path
    @text_type = text_type_from_path(path)
    @attributes, @text = FileParser.attributes_and_text(path)
    @rendered_text = ""
    @@cache[path] = self
  end

  def to_html
    if @rendered_text.empty?
      @rendered_text = render_text
    end
    @rendered_text
  end

  private

  @@cache = {}

  def text_type_from_path(path)
    if path.end_with?(MARKDOWN_SUFFIX) then return TEXT_TYPE_MARKDOWN end
    if path.end_with?(HTML_SUFFIX) then return TEXT_TYPE_HTML end
    return TEXT_TYPE_UNKNOWN
  end

  def render_text
     @text_type == TEXT_TYPE_MARKDOWN ? RDiscount.new(@text).to_html : @text
  end
end
