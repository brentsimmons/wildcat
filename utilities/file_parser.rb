# Parses the attributes at the top of a post.
# Returns the attributes and text.
#
# Works for posts, pages, and wildcat_settings.

require 'Time'
require 'fileutils'

module FileParser
  def self.attributes_and_text(path)
    text = read_whole_file(path)
    attributes = attributes_from_text(text)
    body = body_from_text(text)
    [attributes, body]
  end

  def self.read_whole_file(path)
    file = File.open(path, 'r:UTF-8')
    text = file.read
    file.close
    text
  end

  private

    def self.attributes_from_text(text)
      attributes = {}

      text.each_line do |line|
        one_key, one_value = key_value_with_line(line)
        if one_key.nil?
          break
        else
          attributes[one_key] = one_value
        end
      end

      attributes
    end

    def self.body_from_text(text)
      # Remove @attributes.
      ix = text.index(/^[^@]/)
      return '' if ix.nil?
      text[0, ix] = ''
      text
    end

    def self.key_value_with_line(line)
      return nil, nil if line[0, 1] != '@'

      index_of_space = line.index(' ')
      return nil, nil if index_of_space.nil?

      key = line[1, index_of_space - 1]
      value = line[index_of_space + 1, line.length - (index_of_space + 1)]
      value.strip!

      value = value.to_i if /\D/.match(value).nil? && key != 'title' # it's an integer

      value = '' if value == '(empty-string)'

      value = Time.parse(value) unless /Date$/.match(key).nil?

      unless /Array$/.match(key).nil?
        value = value.split(', ')
        value.map!(&:strip)
      end

      [key, value]
    end
end
