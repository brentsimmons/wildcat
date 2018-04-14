require_relative '../utilities/wildcat_file'

class WebsiteSettings

  attr_reader :attributes # everything
  attr_reader :project_folder
  attr_reader :site_name
  attr_reader :site_url
  attr_reader :output_file_suffix
  attr_reader :output_folder
  attr_reader :rsync_remote_path
  attr_reader :favicon_url
  attr_reader :icon_url
  attr_reader :has_blog

  attr_reader :posts_folder # blog posts
  attr_reader :pages_folder
  attr_reader :styles_folder
  attr_reader :images_folder
  attr_reader :downloads_folder
  attr_reader :templates_folder
  attr_reader :snippets_folder

  attr_reader :images_destination
  attr_reader :styles_destination
  attr_reader :downloads_destination

  attr_reader :blog_output_folder
  attr_reader :blog_number_of_posts
  attr_reader :blog_home_page_title
  attr_reader :blog_archive_title
  attr_reader :blog_url
  attr_reader :blog_relative_path
  attr_reader :blog_month_names

  attr_reader :feed_number_of_posts
  attr_reader :feed_title
  attr_reader :feed_description
  attr_reader :feed_author_name
  attr_reader :feed_author_url
  attr_reader :feed_author_avatar_url
  attr_reader :feed_url

  SITE_NAME_KEY = 'site_name'
  SITE_URL_KEY = 'site_url'
  OUTPUT_FILE_SUFFIX_KEY = 'output_file_suffix'
  OUTPUT_FOLDER_KEY = 'output_folder'
  RSYNC_REMOTE_PATH_KEY = 'rsync_remote_path'
  FAVICON_URL_KEY = 'favicon_url'
  ICON_URL_KEY = 'icon_url'
  HAS_BLOG_KEY = 'has_blog'

  BLOG_NUMBER_OF_POSTS_KEY = 'blog_number_of_posts_on_home_page'
  BLOG_HOME_PAGE_TITLE_KEY = 'blog_home_page_title'
  BLOG_ARCHIVE_TITLE_KEY = 'blog_archive_title'
  BLOG_RELATIVE_PATH_KEY = 'blog_relative_path'
  BLOG_MONTH_NAMES_KEY = 'blog_month_names'

  FEED_NUMBER_OF_POSTS_KEY = 'feed_number_of_posts'
  FEED_TITLE_KEY = 'feed_title'
  FEED_DESCRIPTION_KEY = 'feed_description'
  FEED_AUTHOR_NAME_KEY = 'feed_author'
  FEED_AUTHOR_URL_KEY = 'feed_author_url'
  FEED_AUTHOR_AVATAR_KEY = 'feed_author_avatar_url'

  FOLDER_NAME_POSTS = 'posts'
  FOLDER_NAME_PAGES = 'pages'
  FOLDER_NAME_TEMPLATES = 'templates'
  FOLDER_NAME_SNIPPETS = 'snippets'
  FOLDER_NAME_IMAGES = 'images'
  FOLDER_NAME_STYLES = 'styles'
  FOLDER_NAME_DOWNLOADS = 'downloads'

  def initialize(project_folder, settings_file_path)
    @project_folder = project_folder
    wildcat_file = WildcatFile.new(settings_file_path)
    @attributes = wildcat_file.attributes

    @site_name = @attributes[SITE_NAME_KEY]
    @site_url = @attributes[SITE_URL_KEY]
    @output_file_suffix = @attributes[OUTPUT_FILE_SUFFIX_KEY]
    @output_folder = @attributes[OUTPUT_FOLDER_KEY]
    @rsync_remote_path = @attributes[RSYNC_REMOTE_PATH_KEY]
    @favicon_url = @attributes[FAVICON_URL_KEY]
    @icon_url = @attributes[ICON_URL_KEY]
    @has_blog = @attributes[HAS_BLOG_KEY]

    @posts_folder = File.join(project_folder, FOLDER_NAME_POSTS + '/')
    @pages_folder = File.join(project_folder, FOLDER_NAME_PAGES + '/')
    @styles_folder = File.join(project_folder, FOLDER_NAME_STYLES + '/')
    @images_folder = File.join(project_folder, FOLDER_NAME_IMAGES + '/')
    @downloads_folder = File.join(project_folder, FOLDER_NAME_DOWNLOADS + '/')
    @templates_folder = File.join(project_folder, FOLDER_NAME_TEMPLATES + '/')
    @snippets_folder = File.join(project_folder, FOLDER_NAME_SNIPPETS + '/')

    @images_destination = File.join(@output_folder, FOLDER_NAME_IMAGES + '/')
    @styles_destination = File.join(@output_folder, FOLDER_NAME_STYLES + '/')
    @downloads_destination = File.join(@output_folder, FOLDER_NAME_DOWNLOADS + '/')

    @blog_relative_path = @attributes[BLOG_RELATIVE_PATH_KEY]
    @blog_output_folder = @output_folder
    if !@blog_relative_path.nil? && !@blog_relative_path.empty?
      @blog_output_folder = File.join(@output_folder, @blog_relative_path)
    end

    @blog_number_of_posts = @attributes.fetch(BLOG_NUMBER_OF_POSTS_KEY, 20)
    @blog_home_page_title = @attributes.fetch(BLOG_HOME_PAGE_TITLE_KEY, 'weblog')
    @blog_archive_title = @attributes.fetch(BLOG_ARCHIVE_TITLE_KEY, 'weblog archive')
    @blog_url = site_url
    if !@blog_relative_path.nil? && !@blog_relative_path.empty?
      @blog_url = File.join(blog_url, @blog_relative_path)
    end
    @blog_month_names = @attributes.fetch(BLOG_MONTH_NAMES_KEY, ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'])

    @feed_number_of_posts = @attributes.fetch(FEED_NUMBER_OF_POSTS_KEY, 20)
    @feed_title = @attributes.fetch(FEED_TITLE_KEY, @site_name)
    @feed_description = @attributes[FEED_DESCRIPTION_KEY]
    @feed_author_name = @attributes[FEED_AUTHOR_NAME_KEY]
    @feed_author_url = @attributes[FEED_AUTHOR_URL_KEY]
    @feed_author_avatar_url = @attributes[FEED_AUTHOR_AVATAR_KEY]

    @feed_url = site_url + 'feed.json'
  end
end
