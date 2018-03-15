class RSSFeed

  RSS_TAG = 'rss'
  CHANNEL_TAG = 'channel'
  TITLE_TAG = 'title'
  DESCRIPTION_TAG = 'description'
  ITEM_TAG = 'item'
  LINK_TAG = 'link'
  GUID_TAG = 'guid'
  PUB_DATE_TAG = 'pubDate'

  def self.rendered_feed(settings, posts)
    feed = RSSFeed.new(settings, posts)
    feed.to_s
  end

  def initialize(settings, posts)
    @settings = settings
    @posts = posts
    @xml = '<?xml version="1.0" encoding="UTF-8"?>'
    push_new_line
    @indent_level = 0
    add_header
    add_posts
    add_footer
  end

  def to_s
    @xml
  end

  private

  def add_header
    if @settings.feed_itunes_include
      push_stand_alone_tag('rss version="2.0" xmlns:itunes="http://www.itunes.com/dtds/podcast-1.0.dtd"')
    else
      push_stand_alone_tag('rss version="2.0"')
    end
    @indent_level += 1
    push_stand_alone_tag(CHANNEL_TAG)
    @indent_level += 1
    push_tag_with_value(TITLE_TAG, @settings.feed_title)
    push_tag_with_value(DESCRIPTION_TAG, @settings.feed_description)
  end

  def add_posts
    @posts.each { |post| add_post(post) }
  end

  def add_post(post)
  	push_new_line
    push_stand_alone_tag(ITEM_TAG)
    @indent_level += 1

    if !post.title.nil?
      push_tag_with_value(TITLE_TAG, post.title)
    end

    if post.external_url.nil?
      push_tag_with_value(LINK_TAG, post.permalink)
    else
      push_tag_with_value(LINK_TAG, post.external_url)
    end

    push_tag_with_value(GUID_TAG, post.permalink)

		pub_date_string = post.pub_date.strftime("%a, %d %b %Y %H:%M:%S %z")
    push_tag_with_value(PUB_DATE_TAG, pub_date_string)

    push_tag_with_value(DESCRIPTION_TAG, post.content_html)
    @indent_level -= 1

    push_stand_alone_closing_tag(ITEM_TAG)
  end

  def add_footer
  	push_new_line
    @indent_level -= 1
    push_stand_alone_closing_tag(CHANNEL_TAG)
    @indent_level -= 1
    push_stand_alone_closing_tag(RSS_TAG)
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

  def push_indents
    if @indent_level > 0
      (1..@indent_level).each { push('  ') }
    end
  end

  def push_tag(tag)
    push_indents
    push("<#{tag}>")
  end

  def push_stand_alone_tag(tag)
    push_tag(tag)
    push_new_line
  end

  def push_closing_tag(tag)
    push("</#{tag}>")
    push_new_line
  end

  def push_stand_alone_closing_tag(tag)
    push_indents
    push_closing_tag(tag)
  end

  def push_new_line
    @xml += "\n"
  end

  def push_tag_with_value(tag, value)
    value = xmlize(value)
    push_tag(tag)
    push(value)
    push_closing_tag(tag)
  end

  def push(s)
    @xml += s
  end
end
