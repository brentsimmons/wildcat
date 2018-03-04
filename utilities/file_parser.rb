# Parses the attributes at the top of a post.
# Returns the attributes and text.
#
# Works for posts, pages, and wildcat_settings.


class FileParser

  def self.attributes_and_text(path)

    file = File.new(path)
    pulling_attributes = true
    attributes = {}
    body = ""

    file.each_line do |line|
      if pulling_attributes
        one_key, one_value = key_value_with_line(line)
      end

      if one_key.nil?
        pulling_attributes = false
      else
        attributes[one_key] = one_value
      end

      body += line unless pulling_attributes
    end

    file.close

    return attributes, body
  end

  private

	def self.key_value_with_line(line)
		if line[0,1] != '@' then return nil, nil end

		index_of_space = line.index(' ')
		if index_of_space == nil then return nil, nil end

		key = line[1, index_of_space - 1]
		value = line[index_of_space + 1, line.length - (index_of_space + 1)]
		value.strip!

		if /\D/.match(value) == nil #it's an integer
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
