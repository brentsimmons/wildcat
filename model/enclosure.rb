class Enclosure

  attr_reader :url
  attr_reader :mime_type
  attr_reader :size_in_bytes # String

  ENCLOSURE_URL_KEY = 'enclosure'
  ENCLOSURE_TYPE_KEY = 'enclosureType'
  ENCLOSURE_LENGTH_KEY = 'enclosureLength'

  def initialize(attributes)
    @url = attributes[ENCLOSURE_URL_KEY]
    @mime_type = attributes[ENCLOSURE_TYPE_KEY]
    @size_in_bytes = attributes[ENCLOSURE_LENGTH_KEY].to_s
  end

  JSON_FEED_ENCLOSURE_URL = 'url'
  JSON_FEED_ENCLOSURE_MIME_TYPE = 'mime_type'
  JSON_FEED_ENCLOSURE_SIZE_IN_BYTES = 'size_in_bytes'

  def to_json_feed_component

    if url.nil? || url.is_empty? then return nil end

    json = {}
    json[JSON_FEED_ENCLOSURE_URL] = @url

    add_if_not_empty(json, JSON_FEED_ENCLOSURE_MIME_TYPE, @mime_type)
    add_if_not_empty(json, JSON_FEED_ENCLOSURE_SIZE_IN_BYTES, @size_in_bytes)

    json
  end

  private

  def add_if_not_empty(hash, key, value)
    hash[key] = value unless (value.nil? || value.empty?)
  end
end
