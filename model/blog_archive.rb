class BlogArchive

  def initialize(settings, posts)

  end

  def build
    build_post_archive_pages
    build_month_archive_pages
    build_list_of_months_page
  end

  private

  def build_post_archive_pages
    posts.each { |post| build_single_post_page(post) }
  end

  def build_month_archive_pages
  end

  def build_list_of_months_page
  end

  def build_single_post_page(post)



  end

  def destination_path_for_post_path(path)

    # Change /path/to/project_folder/posts/2018/03/04/some_post.markdown to
    # /path/to/blog_folder/2018/03/04/some_post[suffix]

    relative_path = path
    relative_path[0, @settings.posts_folder.length] = "" # Strip posts folder path.
    blog_path = @settings.blog_destination_folder
    destination_path = File.join(blog_path, relative_path)
    WildcatUtils.change_source_suffix_to_output_suffix(destination_path, @settings.output_file_suffix)
  end

end
