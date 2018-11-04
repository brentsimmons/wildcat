require 'json'

class JSONFeed
  def self.rendered_feed(settings, posts)
    feed = JSONFeed.new(settings, posts)
    feed.to_text
  end

  def initialize(settings, posts)
    @settings = settings
    @posts = posts
  end

  def to_text
    build_feed
  end

  private

    def build_feed
      json_data = {}
      add_header(json_data)
      add_posts(json_data)
      JSON.pretty_generate(json_data)
    end

    def add_header(json_data)
      json_data['version'] = 'https://jsonfeed.org/version/1'

      json_data['user_comment'] = "This feed allows you to read the posts from this site in any feed reader that supports the JSON Feed format. To add this feed to your reader, copy the following URL — #{@settings.feed_url} — and add it your reader."

      json_data['title'] = @settings.feed_title
      json_data['description'] = @settings.feed_description
      json_data['home_page_url'] = @settings.blog_url
      json_data['feed_url'] = @settings.feed_url

      add_if_not_empty(json_data, 'favicon', @settings.favicon_url)
      add_if_not_empty(json_data, 'icon', @settings.icon_url)
      add_if_not_empty(json_data, 'author', author)
    end

    def add_posts(json_data)
      items = @posts.map(&:to_json_feed_component)
      json_data['items'] = items
    end

    def author
      author_name = @settings.feed_author_name
      return if !author_name || author_name.empty?

      author_json = {}
      author_json['name'] = author_name
      add_if_not_empty(author_json, 'url', @settings.feed_author_url)
      add_if_not_empty(author_json, 'avatar', @settings.feed_author_avatar_url)
      author_json
    end

    def add_if_not_empty(hash, key, value)
      hash[key] = value unless value.nil? || value.empty?
    end
end
