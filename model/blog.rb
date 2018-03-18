require_relative '../utilities/wildcat_utils'
require_relative '../utilities/wildcat_file'
require_relative 'json_feed'
require_relative 'rss_feed'
require_relative 'website_settings'
require_relative 'post'
require_relative 'blog_archive'

class Blog

  def initialize(settings)
    @settings = settings
  end

  def build

    @posts = all_blog_posts_reverse_sorted_by_date

    blog_archive = BlogArchive.new(@settings, @posts)
    blog_archive.build

#     build_home_page
    build_json_feed
    build_rss_feed
  end

  private

  def all_blog_posts_reverse_sorted_by_date

    paths = WildcatUtils.text_source_files_in_folder(@settings.posts_folder)

    unsorted_posts = paths.map do |path|
      wildcat_file = WildcatFile.new(path)
      Post.new(@settings, wildcat_file)
    end

    posts = unsorted_posts.sort_by { |post| post.pub_date }
    posts.reverse
  end

  def build_home_page
  end

  def build_json_feed
    feed_text = JSONFeed.rendered_feed(@settings, posts_for_feed)
    write_feed(feed_text, 'feed.json')
  end

  def build_rss_feed
    feed_text = RSSFeed.rendered_feed(@settings, posts_for_feed)
    write_feed(feed_text, 'xml/rss.xml')
  end

  def write_feed(feed_text, relative_path)
    destination_path = File.join(@settings.output_folder, relative_path)
    WildcatUtils.write_file_if_different(destination_path, feed_text)
  end

  def calculate_permalink(path)
    # TODO: figure out permalink for a blog post based on its local path.
  end

  def posts_for_feed
    recent_posts(@settings.feed_number_of_posts)
  end

  def posts_for_home_page
    recent_posts(@settings.blog_number_of_posts)
  end

  def recent_posts(count)
    last_post_index = count - 1
    @posts[0..last_post_index]
  end
end
