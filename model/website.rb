require_relative 'page'
require_relative 'blog'
require_relative '../utilities/wildcat_utils'

class Website
  attr_reader :blog

  def initialize(settings)
    @settings = settings
    @blog = Blog.new(@settings) if @settings.has_blog
  end

  def build
    build_pages

    @blog.build if @settings.has_blog

    copy_files
  end

  private

    def build_pages
      Page.build_all_pages(@settings)
    end

    # Files in images/, styles/, and downloads/ are copied
    # to corresponding folders in output.

    def copy_files
      copy_images
      copy_downloads
      copy_style_sheets
    end

    def copy_images
      WildcatUtils.rsync_local(@settings.images_folder, @settings.images_destination)
    end

    def copy_style_sheets
      WildcatUtils.rsync_local(@settings.styles_folder, @settings.styles_destination)
    end

    def copy_downloads
      WildcatUtils.rsync_local(@settings.downloads_folder, @settings.downloads_destination)
    end
end
