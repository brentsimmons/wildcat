require_relative 'enclosure'

class Post

  attr_reader :permalink
  attr_reader :external_url
  attr_reader :title
  attr_reader :content_html
  attr_reader :pub_date
  attr_reader :enclosure
  attr_reader :attributes

  TITLE_KEY = 'title'
  LINK_KEY = 'link'
  PUB_DATE_KEY = 'pubDate'

  def initialize(permalink, file) # file is a WildcatFile
    @permalink = permalink
    @attributes = file.attributes
    @external_url = @attributes[LINK_KEY]
    @title = @attributes[TITLE_KEY]
    @content_html = file.to_html
    @pub_date = @attributes[PUB_DATE_KEY]

    enclosure_url = @attributes[ENCLOSURE_URL_KEY]
    if !enclosure_url.nil? && !enclosure_url.empty?
      @enclosure = Enclosure(@attributes)
    end
  end

  JSON_FEED_URL_KEY = 'url'
  JSON_FEED_EXTERNAL_URL_KEY = 'external_url'
  JSON_FEED_ID_KEY = 'id'
  JSON_FEED_TITLE_KEY = 'title'
  JSON_FEED_CONTENT_HTML_KEY = 'content_html'
  JSON_FEED_PUB_DATE_KEY = 'date_published'
  JSON_FEED_ATTACHMENTS_KEY = 'attachments'

  def to_json_feed_component

    json = {}
    json[JSON_FEED_ID_KEY] = @permalink
    json[JSON_FEED_URL_KEY] = @permalink
    json[JSON_FEED_CONTENT_HTML_KEY] = @content_html

    date_string = @pub_date.iso8601
    json[JSON_FEED_PUB_DATE_KEY] = date_string

    add_if_not_empty(json, JSON_FEED_EXTERNAL_URL_KEY, @external_url)

    if enclosure
      enclosure_json = enclosure.to_json_feed_component
      json[JSON_FEED_ATTACHMENTS_KEY] = [enclosure_json]
    end

    json
  end

  private

  def add_if_not_empty(json, key, value)
    json[key] = value unless (!value || value.empty?)
  end
end
