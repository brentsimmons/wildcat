# Parses the attributes at the top of a post.
# Returns the attributes and text.
#
# Works for posts, pages, and wildcat_settings.

require 'Time'
require 'fileutils'

module FileParser

  def FileParser.attributes_and_text(path)
    text = read_whole_file(path)
    attributes = attributes_from_text(text)
    body = body_from_text(text)
    return attributes, body
  end

  def FileParser.read_whole_file(path)
    file = File.open(path, 'r:UTF-8')
    text = file.read
    file.close
    text
  end

  private

  def FileParser.attributes_from_text(text)

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

  def FileParser.body_from_text(text)
    # Remove @attributes.
    ix = text.index(/^[^@]/)
    if ix == nil then return "" end
    text[0,ix] = ""
    text
  end

	def FileParser.key_value_with_line(line)
		if line[0,1] != '@' then return nil, nil end

		index_of_space = line.index(' ')
		if index_of_space == nil then return nil, nil end

		key = line[1, index_of_space - 1]
		value = line[index_of_space + 1, line.length - (index_of_space + 1)]
		value.strip!

		if /\D/.match(value) == nil && key != 'title' #it's an integer
			value = value.to_i
		end

		if value == '(empty-string)' then value = '' end

		if /Date$/.match(key) != nil then value = Time.parse(value) end

		if /Array$/.match(key) != nil
			value = value.split(', ')
			value.map!(&:strip)
		end

		return key, value
	end
end
