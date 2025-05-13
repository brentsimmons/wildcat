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
    build_archive_page
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
    title = post.title
    if title.nil? || title.empty?
      title = post.pub_date.strftime("%d %b %Y %H:%M:%S %z")
    end

    context = {}
    context[CONTEXT_TITLE_KEY] = title
    context[CONTEXT_CONTENT_HTML_KEY] = post.to_html(false) # not including permalink
    PageBuilder.build(@settings, 'archive_single_post', context, post.destination_path)
  end

  def build_archive_page
    context = {}
    context[CONTEXT_TITLE_KEY] = @settings.blog_archive_title
    context[CONTEXT_CONTENT_HTML_KEY] = archive_page_html

    destination_path = File.join(@settings.blog_output_folder, 'archive')
    destination_path = WildcatUtils.add_suffix_if_needed(destination_path, @settings.output_file_suffix)
    PageBuilder.build(@settings, 'archive_index', context, destination_path)
  end

  def sorted_years
    years = @years.values.sort_by { |blog_year| blog_year.year }
    years.reverse
  end

  def archive_page_html
    html = ''
    for blog_year in sorted_years
      html = html + render_year_section(blog_year)
    end
    html
  end

  def render_year_section(blog_year)
    sorted_months = blog_year.months.values.sort_by { |blog_month| blog_month.month }
    sorted_months.reverse!

    html = ''
    for blog_month in sorted_months
      html = html + render_month_section(blog_year, blog_month)
    end
    html
  end

  def render_month_section(blog_year, blog_month)
    month_name = @settings.blog_month_names[blog_month.month - 1]
    html = "<h2>#{month_name} #{blog_year.year}</h2>\n<ul>\n"
    
    # Sort posts by date within the month
    sorted_posts = blog_month.posts.sort_by { |post| post.pub_date }
    sorted_posts.reverse!
    
    sorted_posts.each do |post|
      html = html + render_post_item(post)
    end
    
    html = html + "</ul>\n"
    html
  end

  def render_post_item(post)
    title = post.display_title
    url = post.permalink
    date = post.pub_date.strftime("%d&nbsp;%b")
    "<li><a href=\"#{url}\">#{title}</a> <span class=\"date\">#{date}</span></li>\n"
  end
end
