# Implements MetaWeblog API.
# Does not implement Blogger API.
# This means no API for deleting a post. You have to delete posts manually.
# This is on purpose.
#
# All posts created here are assumed to be Markdown.
#
# Error handling is via exceptions.
# Not my preferred thing, but it works well with XML-RPC.

require 'xmlrpc/server'
require_relative '../wildcat'
require_relative '../model/website'
require_relative '../model/blog'
require_relative '../model/post'
require_relative '../utilities/wildcat_file'
require_relative '../utilities/wildcat_utils'

class MetaWeblogCommand

  TITLE_KEY = 'title'
  LINK_KEY = 'link'
  POSTID_KEY = 'postid'
  PERMALINK_KEY = 'permaLink'
  DESCRIPTION_KEY = 'description'
  DATE_CREATED_KEY = 'dateCreated'
  ENCLOSURE_STRUCT_KEY = 'enclosure'
  ENCLOSURE_LENGTH_KEY = 'length'
  ENCLOSURE_TYPE_KEY = 'type'
  ENCLOSURE_URL_KEY = 'url'

  EXCEPTION_MESSAGE_LOGIN_INVALID = 'Invalid login'
  EXCEPTION_CODE_LOGIN_INVALID = 0
  EXCEPTION_MESSAGE_CANT_FIND_WEBSITES_FOLDER = 'Can’t find websites folder'
  EXCEPTION_CODE_CANT_FIND_WEBSITES_FOLDER = 1
  EXCEPTION_MESSAGE_UNIMPLEMENTED = 'Unimplemented method'
  EXCEPTION_CODE_UNIMPLEMENTED = 2
  EXCEPTION_MESSAGE_CANT_FIND_POST = 'Can’t find post'
  EXCEPTION_CODE_CANT_FIND_POST = 3

  def initialize(username, password, blog_id)
    # TODO: authenticate
    raise XMLRPC::FaultException.new(EXCEPTION_MESSAGE_LOGIN_INVALID, EXCEPTION_CODE_LOGIN_INVALID)
    @blog_id = blog_id
    @wildcat = wildcat
  end

  # API

  def recent_posts(number_of_posts)
    posts = @wildcat.website.blog.recent_posts(number_of_posts)
    posts.map { |post| hash_for_post(blog_id, post) }
  end

  def get_post(post_id)
    unused, relative_path = MetaWeblogCommand.split_post_id(post_id)
    path = File.join(@wildcat.settings.posts_folder, relative_path)
    post = Post.new(@wildcat.settings, path)
    hash_for_post(post)
  end

  def new_post(struct)
    title = struct[TITLE_KEY]
    description = struct[DESCRIPTION_KEY]
    file_name = file_name_for_new_post(title, description)
    relative_folder_path = relative_folder_path_with_date(Time.now)
    relative_path = File.join(relative_folder_path, file_name)
    path = File.join(@wildcat.settings.posts_folder, relative_path)
    text = post_text_with_struct(struct)
    WildcatUtils.write_file_if_different(path, text)
    post_id_with_relative_path(relative_path)
  end

  def edit_post(post_id, struct)

  end

  def get_categories
    # Wildcat doesn’t support categories.
    {}
  end

  def new_media_object(blog_id, struct)
    # TODO: support this.
    raise XMLRPC::FaultException.new(EXCEPTION_MESSAGE_UNIMPLEMENTED, EXCEPTION_CODE_UNIMPLEMENTED)
  end

  # Utility

  def MetaWeblogCommand.split_post_id(post_id)
    components = post_id.split(':')
    blog_id = components[0]
    relative_path = components[1]
    return blog_id, relative_path
  end

  private

  def create_post_id(post)
    post_id_with_relative_path(post.relative_path)
  end

  def post_id_with_relative_path(relative_path)
    @blog_id + ':' + relative_path
  end

  def hash_for_post(post)
    h = {}
    h[POSTID_KEY] = create_post_id(@blog_id, post)
    h[DESCRIPTION_KEY] = post.source_text
    h[DATE_CREATED_KEY] = post.pubDate
    h[PERMALINK_KEY] = post.permalink
    h[TITLE_KEY] = post.title unless post.title.nil? || post.title.empty?
    h[LINK_KEY] = post.external_url unless post.external_url.nil? || post.external_url.empty?
    # TODO: enclosures
    h
  end

  def wildcat
    if @blog_id.nil? || @blog_id.empty? || @blog_id.include? '..'
      raise_cant_find_websites_folder
    end

    websites_folder = ENV[ENV_KEY_WEBSITES_FOLDER]
    if websites_folder.nil? || websites_folder.empty?
      raise_cant_find_websites_folder
    end

    project_folder = File.join(websites_folder, @blog_id)
    Wildcat.new(project_folder, nil)
  end

  def raise_cant_find_websites_folder
    raise XMLRPC::FaultException.new(EXCEPTION_CODE_CANT_FIND_WEBSITES_FOLDER, EXCEPTION_CODE_CANT_FIND_WEBSITES_FOLDER)
  end

  def file_name_for_new_post(title, description)
    file_name = title.dup
    if file_name.nil? || file_name.empty?
      file_name = description.dup
    end
    file_name.chomp!
    file_name.downcase!
    file_name.gsub!(' ', '_')
    file_name.gsub!(/\W/, '_')
    while file_name.include('__')
      file_name.gsub!('__', '_')
    end
    if file_name.length > 40
      file_name = file_name[0, 40]
    end
    file_name + '.markdown'
  end

  def relative_folder_path_with_date(date)
    date.strftime("%Y/%m/%d/")
  end
end


#   def self.rawTextWithStruct(h)
#     s = String.new()
#     s += ExportUtils.attLine(h["title"], "title")
#     link = h["link"]
#     if link != nil && link != ""
#       s += ExportUtils.attLine(link, "link")
#     end
#     categories = h["categories"]
#     if categories != nil && !categories.empty?()
#       s += ExportUtils.attLine(categories.join(", "), "categoryArray")
#     end
#     d = Time.new()
#     pubDate = h["pubDate"]
#     if pubDate == nil then pubDate = d end
#     modDate = h["modDate"]
#     if modDate == nil then modDate = d end
#     s += ExportUtils.attLine("#{pubDate}", "pubDate")
#     s += ExportUtils.attLine("#{modDate}", "modDate")
#     s += h["description"]
#     return s
#   end
#   def self.editPost(website, filePath, h)
#     if !FileTest.exist?(filePath)
#       raise XMLRPC::FaultException.new(0, "post doesn’t exist")
#     end
#     existingWeblogPost = WeblogPost.new(website, filePath)
#     h["pubDate"] = existingWeblogPost.atts["pubDate"]
#     rawText = rawTextWithStruct(h)
#     ExportUtils.writeFileToDisk(rawText, filePath)
#   end
#
# end

class MetaWeblogAPI

  def getRecentPosts(blog_id, username, password, number_of_posts)
    command = MetaWeblogCommand.new(username, password, blog_id)
    command.recent_posts(number_of_posts)
  end

  def getCategories(blog_id, username, password)
    # Wildcat doesn’t support categories, but this shouldn’t be seen as an error.
    command = MetaWeblogCommand.new(username, password, blog_id)
    command.get_categories
  end

  def getPost(post_id, username, password)
    blog_id, unused = MetaWeblogCommand.split_post_id(post_id)
    command = MetaWeblogCommand.new(username, password, blog_id)
    command.get_post(post_id)
  end

  def newPost(blog_id, username, password, struct, publish)
    command = MetaWeblogCommand.new(username, password, blog_id)
    command.new_post(struct) # The publish parameter is ignored.
  end

  def editPost(post_id, username, password, struct, publish)
    blog_id, unused = MetaWeblogCommand.split_post_id(post_id)
    command = MetaWeblogCommand.new(username, password, blog_id)
    command.edit_post(post_id, struct) # The publish parameter is ignored.
    return true
  end

  def newMediaObject(blog_id, username, password, struct)
    command = MetaWeblogCommand.new(username, password, blog_id)
    command.new_media_object(struct)
  end
end

s = XMLRPC::CGIServer.new()
s.add_handler("metaWeblog", MetaWeblogAPI.new())
s.serve()
