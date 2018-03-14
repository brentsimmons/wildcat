require_relative '../utilities/wildcat_file'

class WebsiteSettings

  attr_reader :attributes # everything
  attr_reader :project_folder
  attr_reader :site_name
  attr_reader :site_url
  attr_reader :output_file_suffix
  attr_reader :output_folder
  attr_reader :rsync_path
  attr_reader :favicon_url
  attr_reader :icon_url
  attr_reader :has_blog
  attr_reader :style_sheet_url

  attr_reader :posts_folder # blog posts
  attr_reader :pages_folder
  attr_reader :styles_folder
  attr_reader :images_folder
  attr_reader :downloads_folder
  attr_reader :templates_folder
  attr_reader :snippets_folder

  attr_reader :blog_output_folder
  attr_reader :blog_number_of_posts
  attr_reader :blog_home_page_title
  attr_reader :blog_archive_title
  attr_reader :blog_url
  attr_reader :blog_relative_path

  attr_reader :feed_number_of_posts
  attr_reader :feed_title
  attr_reader :feed_description
  attr_reader :feed_author_name
  attr_reader :feed_author_url
  attr_reader :feed_author_avatar_url
  attr_reader :feed_url
  attr_reader :feed_itunes_include
  attr_reader :feed_itunes_graphic_url
  attr_reader :feed_itunes_author
  attr_reader :feed_itunes_summary
  attr_reader :feed_itunes_keywords
  attr_reader :feed_itunes_explicit
  attr_reader :feed_itunes_owner_name
  attr_reader :feed_itunes_owner_email
  attr_reader :feed_itunes_category

  SITE_NAME_KEY = 'site_name'
  SITE_URL_KEY = 'site_url'
  OUTPUT_FILE_SUFFIX_KEY = 'output_file_suffix'
  OUTPUT_FOLDER_KEY = 'output_folder'
  RSYNC_PATH_KEY = 'rsync_path'
  FAVICON_URL_KEY = 'favicon_url'
  ICON_URL_KEY = 'icon_url'
  HAS_BLOG_KEY = 'has_blog'

  BLOG_NUMBER_OF_POSTS_KEY = 'blog_number_of_posts_on_home_page'
  BLOG_HOME_PAGE_TITLE_KEY = 'blog_home_page_title'
  BLOG_ARCHIVE_TITLE_KEY = 'blog_archive_title'
  BLOG_RELATIVE_PATH_KEY = 'blog_relative_path'

  FEED_NUMBER_OF_POSTS_KEY = 'feed_number_of_posts'
  FEED_TITLE_KEY = 'feed_title'
  FEED_DESCRIPTION_KEY = 'feed_description'
  FEED_AUTHOR_NAME_KEY = 'feed_author'
  FEED_AUTHOR_URL_KEY = 'feed_author_url'
  FEED_AUTHOR_AVATAR_KEY = 'feed_author_avatar_url'
  FEED_ITUNES_INCLUDE = 'feed_itunes_include'
  FEED_ITUNES_GRAPHIC_URL = 'feed_itunes_graphic_url'
  FEED_ITUNES_AUTHOR = 'feed_itunes_author'
  FEED_ITUNES_SUMMARY = 'feed_itunes_summary'
  FEED_ITUNES_KEYWORDS = 'feed_itunes_keywords'
  FEED_ITUNES_EXPLICIT = 'feed_itunes_explicit'
  FEED_ITUNES_OWNER_NAME = 'feed_itunes_owner_name'
  FEED_ITUNES_OWNER_EMAIL = 'feed_itunes_owner_email'
  FEED_ITUNES_CATEGORY = 'feed_itunes_category'

  def initialize(project_folder, settings_file_path)
    @project_folder = project_folder
    wildcat_file = WildcatFile.new(settings_file_path)
    @attributes = wildcat_file.attributes

    @site_name = @attributes[SITE_NAME_KEY]
    @site_url = @attributes[SITE_URL_KEY]
    @output_file_suffix = @attributes[OUTPUT_FILE_SUFFIX_KEY]
    @output_folder = @attributes[OUTPUT_FOLDER_KEY]
    @rsync_path = @attributes[RSYNC_PATH_KEY]
    @favicon_url = @attributes[FAVICON_URL_KEY]
    @icon_url = @attributes[ICON_URL_KEY]
    @has_blog = @attributes[HAS_BLOG_KEY]
    @style_sheet_url = File.join(@site_url, 'styles/styleSheet.css')

    @posts_folder = File.join(project_folder, 'posts/')
    @pages_folder = File.join(project_folder, 'pages/')
    @styles_folder = File.join(project_folder, 'styles/')
    @images_folder = File.join(project_folder, 'images/')
    @downloads_folder = File.join(project_folder, 'downloads/')
    @templates_folder = File.join(project_folder, 'templates/')
    @snippets_folder = File.join(project_folder, 'snippets/')

    @blog_relative_path = @attributes[BLOG_RELATIVE_PATH_KEY]
    @blog_output_folder = @output_folder
    if !@blog_relative_path.nil? && !@blog_relative_path.empty?
      @blog_output_folder = File.join(@output_folder, @blog_relative_path)
    end

    @blog_number_of_posts = @attributes.fetch(BLOG_NUMBER_OF_POSTS_KEY, 20)
    @blog_home_page_title = @attributes.fetch(BLOG_HOME_PAGE_TITLE_KEY, 'weblog')
    @blog_archive_title = @attributes.fetch(BLOG_ARCHIVE_TITLE_KEY, 'weblog archive')
    @blog_url = @blog_relative_path ? site_url + @blog_relative_path : site_url

    @feed_number_of_posts = @attributes.fetch(FEED_NUMBER_OF_POSTS_KEY, 20)
    @feed_title = @attributes.fetch(FEED_TITLE_KEY, @site_name)
    @feed_description = @attributes[FEED_DESCRIPTION_KEY]
    @feed_author_name = @attributes[FEED_AUTHOR_NAME_KEY]
    @feed_author_url = @attributes[FEED_AUTHOR_URL_KEY]
    @feed_author_avatar_url = @attributes[FEED_AUTHOR_AVATAR_KEY]
    @feed_itunes_include = @attributes[FEED_ITUNES_INCLUDE]
    @feed_itunes_graphic_url = @attributes[FEED_ITUNES_GRAPHIC_URL]
    @feed_itunes_author = @attributes[FEED_ITUNES_AUTHOR]
    @feed_itunes_summary = @attributes[FEED_ITUNES_SUMMARY]
    @feed_itunes_keywords = @attributes[FEED_ITUNES_KEYWORDS]
    @feed_itunes_explicit = @attributes[FEED_ITUNES_EXPLICIT]
    @feed_itunes_owner_name = @attributes[FEED_ITUNES_OWNER_NAME]
    @feed_itunes_owner_email = @attributes[FEED_ITUNES_OWNER_EMAIL]
    @feed_itunes_category = @attributes[FEED_ITUNES_CATEGORY]

    @feed_url = site_url + 'feed.json'
  end
end
