require_relative 'page'
require_relative 'blog'

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

#     copy_files
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
  end

  def copy_style_sheets
  end

  def copy_downloads
  end
end
