require_relative 'post'

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
    @posts.each { |post| build_single_post_page(post) }
  end

  def build_single_post_page(post)
    context = {}
    context[CONTEXT_TITLE_KEY] = post.title
    context[CONTEXT_CONTENT_HTML_KEY] = post.to_html(false) # not including permalink
    renderer = Renderer.new(@settings, 'post_single_page', context)
    WildcatUtils.write_file_if_different(post.destination_path, renderer.to_html)
  end

  def build_month_pages
  end

  def build_year_month_index_page
  end
end
