require_relative 'page'
require_relative 'blog'
require_relative '../utilities/wildcat_utils'

class Website

  def initialize(settings)
    @settings = settings
  end

  def build

    build_pages

    if @settings.has_blog
      blog = Blog.new(@settings)
      blog.build
    end

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
