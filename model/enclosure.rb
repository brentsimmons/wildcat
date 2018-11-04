require_relative '../wildcat_constants'

class Enclosure
  attr_reader :url
  attr_reader :mime_type
  attr_reader :size_in_bytes # String

  ENCLOSURE_URL_KEY = 'enclosure'.freeze
  ENCLOSURE_TYPE_KEY = 'enclosureType'.freeze
  ENCLOSURE_LENGTH_KEY = 'enclosureLength'.freeze

  def initialize(attributes)
    @url = attributes[ENCLOSURE_URL_KEY]
    @mime_type = attributes[ENCLOSURE_TYPE_KEY]
    @size_in_bytes = attributes[ENCLOSURE_LENGTH_KEY].to_s
  end

  def to_json_feed_component
    return nil if url.nil? || url.empty?

    json = {}
    json[JSON_FEED_ENCLOSURE_URL] = @url

    add_if_not_empty(json, JSON_FEED_ENCLOSURE_MIME_TYPE, @mime_type)
    unless @size_in_bytes.nil?
      json[JSON_FEED_ENCLOSURE_SIZE_IN_BYTES] = @size_in_bytes.to_i
    end

    json
  end

  private

    def add_if_not_empty(hash, key, value)
      hash[key] = value unless value.nil? || value.empty?
    end
end
