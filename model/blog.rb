class Blog

  def initialize(settings)
    @settings = settings
  end

  def build
    build_post_archive_pages # Individual pages per post
    build_month_archive_pages
    build_list_of_months_page
    build_home_page
    build_json_feed
    build_rss_feed
  end

  private

  def build_post_archive_pages
  end

  def build_month_archive_pages
  end

  def build_list_of_months_page
  end

  def build_home_page
  end

  def build_json_feed
  end

  def build_rss_feed
  end
end
