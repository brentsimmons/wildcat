class RSSFeed

  # Feeds are rendered using an 'rss' template in the templates folder.
  # The individual items are generated programatically.

  ITEMS_KEY = 'items'
  SITE_NAME_KEY = 'site_name'
  SITE_URL_KEY = 'site_url'
  FEED_DESCRIPTION_KEY = 'feed_description'

  def self.rendered_feed(settings, posts)
    feed = RSSFeed.new(settings, posts)
    feed.to_s
  end

  def initialize(settings, posts)
    @settings = settings
    @posts = posts
  end

  def to_s
    items = ''
    @posts.each { |post| items += render_post(post) }

    context = {}
    context[ITEMS_KEY] = items
    context[SITE_NAME_KEY] = xmlize(@settings.site_name)
    context[SITE_URL_KEY] = xmlize(@settings.site_url)
    context[FEED_DESCRIPTION_KEY] = xmlize(@settings.feed_description)

    renderer = Renderer.new(@settings, 'rss', context)
    renderer.to_s
  end

  private

  def render_post(post)
    rss_item = RSSItem.new(@settings, post, 2)
    rss_item.to_s + "\n"
  end
end

class RSSItem

  TITLE_TAG = 'title'
  DESCRIPTION_TAG = 'description'
  ITEM_TAG = 'item'
  LINK_TAG = 'link'
  GUID_TAG = 'guid'
  PUB_DATE_TAG = 'pubDate'
  ENCLOSURE_TAG = 'enclosure'
  URL_ATTRIBUTE = 'url'
  ENCLOSURE_LENGTH_ATTRIBUTE = 'length'
  ENCLOSURE_TYPE_ATTRIBUTE = 'type'
  ITUNES_AUTHOR_TAG = 'itunes:author'
  ITUNES_SUMMARY_TAG = 'itunes:summary'
  ITUNES_KEYWORDS_TAG = 'itunes:keywords'
  ITUNES_EXPLICIT_TAG = 'itunes:explicit'
  ITUNES_IMAGE_TAG = 'itunes:image'
  HREF_ATTRIBUTE = 'href'
  ITUNES_OWNER_TAG = 'itunes:owner'
  ITUNES_NAME_TAG = 'itunes:name'
  ITUNES_EMAIL_TAG = 'itunes:email'
  ITUNES_DURATION_TAG = 'itunes:duration'
  ITUNES_SUBTITLE_TAG = 'itunes:subtitle'
  MEDIA_THUMBNAIL_TAG = 'media:thumbnail'

  def initialize(settings, post, indent_level)
    @settings = settings
    @post = post
    @indent_level = indent_level
    @xml = ''
  end

  def to_s
    push_stand_alone_tag(ITEM_TAG)
    @indent_level += 1
    if !@post.title.nil?
      push_tag_with_value(TITLE_TAG, @post.title)
    end

    if @post.external_url.nil?
      push_tag_with_value(LINK_TAG, @post.permalink)
    else
      push_tag_with_value(LINK_TAG, @post.external_url)
    end

    push_tag_with_value(GUID_TAG, @post.permalink)

		pub_date_string = @post.pub_date.strftime("%a, %d %b %Y %H:%M:%S %z")
    push_tag_with_value(PUB_DATE_TAG, pub_date_string)

    push_tag_with_value(DESCRIPTION_TAG, @post.content_html)
    @indent_level -= 1

    push_enclosure unless @post.enclosure.nil?

    push_stand_alone_closing_tag(ITEM_TAG)
  end

  def push_enclosure
    push_indents
    push('<enclosure')
    push_attribute('url', @post.enclosure.url)
    push_attribute_if_not_empty('length', @post.enclosure.size_in_bytes.to_s)
    push_attribute_if_not_empty('type', @post.enclosure.mime_type)
    push(' />')
    push_new_line

    push_tag_with_value_if_not_empty('itunes:duration', @post.itunes_duration)
    push_tag_with_value_if_not_empty('itunes:subtitle', @post.itunes_subtitle)
    push_tag_with_value_if_not_empty('itunes:summary', @post.itunes_summary)
    push_tag_with_value_if_not_empty('itunes:explicit', @post.itunes_explicit)

    if @post.media_thumbnail.nil? || post.media_thumbnail.empty?
      push_tag_with_value_if_not_empty('media:thumbnail', @settings.feed_media_thumbnail)
    else
      push_tag_with_value_if_not_empty('media:thumbnail', @post.media_thumbnail)
    end
  end

  def push_attribute_if_not_empty(name, value)
    push_attribute(name, value) unless value.nil? || value.empty?
  end

  def push_attribute(name, value)
    push(" #{name}=\"#{xmlize(value)}\"")
  end

  def push_indents
    if @indent_level > 0
      (1..@indent_level).each { push('  ') }
    end
  end

  def push_stand_alone_tag(tag)
    push_tag(tag)
    push_new_line
  end

  def push_tag(tag)
    push_indents
    push("<#{tag}>")
  end

  def push_closing_tag(tag)
    push("</#{tag}>")
    push_new_line
  end

  def push_stand_alone_closing_tag(tag)
    push_indents
    push_closing_tag(tag)
  end

  def push_tag_with_value_if_not_empty(tag, value)
    if value.nil? || value.empty? then return end
    push_tag_with_value(tag, value)
  end

  def push_tag_with_value(tag, value)
    value = xmlize(value)
    push_tag(tag)
    push(value)
    push_closing_tag(tag)
  end

  def push_new_line
    @xml += "\n"
  end

  def push(s)
    @xml += s
  end
end


def xmlize(s)
  xml = s
  xml.gsub!('&', '&amp;')
  xml.gsub!('<', '&lt;')
  xml.gsub!('>', '&gt;')
  xml.gsub!("'", '&apos;')
  xml.gsub!('"', '&quot;')
  xml.strip!
  xml
end

