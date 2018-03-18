require_relative 'post'
require_relative 'blog_year'
require_relative '../renderer/page_builder'
require_relative '../utilities/wildcat_utils'

class BlogArchive

  def initialize(settings, posts)
    @settings = settings
    @posts = posts
    @years = {}
    sort_into_years_and_months
  end

  def build
    build_single_post_pages
    build_month_pages
    build_year_month_index_page
  end

  private

  def sort_into_years_and_months
    @posts.each { |post| add_to_year(post) }
  end

  def add_to_year(post)
    year = post.pub_date.year
    blog_year = @years[year]
    if blog_year.nil?
      blog_year = BlogYear.new(year)
      @years[year] = blog_year
    end
    blog_year.add_post(post)
  end

  def build_single_post_pages
    @posts.each { |post| build_single_post_page(post) }
  end

  def build_single_post_page(post)
    context = {}
    context[CONTEXT_TITLE_KEY] = post.title
    context[CONTEXT_CONTENT_HTML_KEY] = post.to_html(false) # not including permalink
    PageBuilder.build(@settings, 'post_single_page', context, post.destination_path)
  end

  def build_month_pages
  end

  def build_year_month_index_page
    context = {}
    context[CONTEXT_TITLE_KEY] = @settings.blog_archive_title
    context[CONTEXT_CONTENT_HTML_KEY] = archive_index_html

    destination_path = File.join(@settings.blog_output_folder, 'archive')
    destination_path = WildcatUtils.add_suffix_if_needed(destination_path, @settings.output_file_suffix)
    PageBuilder.build(@settings, 'archive', context, destination_path)
  end

  def sorted_years
    years = @years.values.sort_by { |blog_year| blog_year.year }
    years.reverse
  end

  def archive_index_html
    html = ''
    for blog_year in sorted_years
      html = html + render_year_index(blog_year)
    end
    html
  end

  def render_year_index(blog_year)
    sorted_months = blog_year.months.values.sort_by { |blog_month| blog_month.month }
    sorted_months.reverse!

    html = "<h4>#{blog_year.year}</h4>\n<ul>\n"
    for blog_month in sorted_months
      html = html + render_month_item(blog_year, blog_month)
    end

    html = html + "</ul>\n"
    html
  end

  def render_month_item(blog_year, blog_month)
    month_name = @settings.blog_month_names[blog_month.month - 1]
    url = month_item_link(blog_year, blog_month)
    "<li><a href=#{url}>#{month_name}</a></li>\n"
  end

  def month_item_link(blog_year, blog_month)
    month_string = blog_month.month.to_s.rjust(2, '0')
    "#{blog_year.year}/#{month_string}/"
  end
end
