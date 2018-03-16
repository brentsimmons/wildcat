class BlogArchive

  def initialize(settings, posts)
    @settings = settings
    @posts = posts
  end

  def build
    build_single_post_pages
    build_month_pages
    build_year_month_index_page
  end

  private

  def build_single_post_pages
  end

  def build_month_pages
  end

  def build_year_month_index_page
  end
end
