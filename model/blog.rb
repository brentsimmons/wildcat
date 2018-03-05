class Blog

  def initialize(settings)
    @settings = settings
  end

  def build

    @posts = all_blog_posts_reverse_sorted_by_date

    blog_archive = BlogArchive.new(settings, posts)
    blog_archive.build

    build_home_page
    build_json_feed
    build_rss_feed
  end

  private

  def all_blog_posts_reverse_sorted_by_date
  end

  def build_home_page
  end

  def build_json_feed
  end

  def build_rss_feed
  end
end
