require 'xmlrpc/server'
require_relative '../wildcat'
require_relative '../model/website'
require_relative '../model/blog'
require_relative '../model/post'
require_relative '../utilities/wildcat_file'

# Implements MetaWeblog API.
# Does not implement Blogger API.
# This means no API for deleting a post. You have to delete posts manually.
# This is on purpose.
#
# All posts created here are assumed to be Markdown.
#
# Error handling is via exceptions.
# Not my preferred thing, but it works well with XML-RPC.

class PostSpecifier

  attr_reader :blog_id
  attr_reader :relative_path

  def initialize(post_id)
    components = post_id.split(':')
    @blog_id = components[0]
    @relative_path = components[1]
    project_folder = BlogAPIHelper.folder_for_website(blog_id)
    @settings = Wildcat.settings_with_file_name(project_folder, nil)
    @path = File.join(@settings.posts_folder, @relative_path)
  end

  def wildcat_file
    WildcatFile.new(@path)
  end

  def post
    Post.new(@settings, wildcat_file)
  end
end

module BlogAPIHelper

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

  ENV_KEY_WEBSITES_FOLDER = 'WILDCAT_WEBSITES_FOLDER'

  EXCEPTION_MESSAGE_LOGIN_INVALID = 'Invalid login'
  EXCEPTION_CODE_LOGIN_INVALID = 0
  EXCEPTION_MESSAGE_CANT_FIND_WEBSITES_FOLDER = 'Can’t find websites folder'
  EXCEPTION_CODE_CANT_FIND_WEBSITES_FOLDER = 1
  EXCEPTION_MESSAGE_UNIMPLEMENTED = 'Unimplemented method'
  EXCEPTION_CODE_UNIMPLEMENTED = 2
  EXCEPTION_MESSAGE_CANT_FIND_POST = 'Can’t find post'
  EXCEPTION_CODE_CANT_FIND_POST = 3

  def BlogAPIHelper.check_auth(username, password)

    BlogAPIHelper.raise_xmlrpc_exception(EXCEPTION_MESSAGE_LOGIN_INVALID, EXCEPTION_CODE_LOGIN_INVALID)
  end

  def BlogAPIHelper.hash_for_post(blog_id, post)
    h = {}
    h[POSTID_KEY] = BlogAPIHelper.post_id(blog_id, post)
    h[DESCRIPTION_KEY] = post.source_text
    h[DATE_CREATED_KEY] = post.pubDate
    h[PERMALINK_KEY] = post.permalink
    h[TITLE_KEY] = post.title unless post.title.nil? || post.title.empty?
    h[LINK_KEY] = post.external_url unless post.external_url.nil? || post.external_url.empty?
    h
  end

  def BlogAPIHelper.post_id(blog_id, post)
    blog_id + ':' + post.relative_path
  end

  def BlogAPIHelper.project_folder_with_blog_id(blog_id)

    if blog_id.include? '..'
      BlogAPIHelper.raise_cant_find_websites_folder
    end

    websites_folder = ENV[ENV_KEY_WEBSITES_FOLDER]
    if websites_folder.nil? || websites_folder.empty?
      BlogAPIHelper.raise_cant_find_websites_folder
    end

    File.join(websites_folder, blog_id)
  end

  def path_for_post(post_id)

  end

  def BlogAPIHelper.blog_id_from_post_id(post_id)

  end

  def BlogAPIHelper.add_post(blog_id, post_struct)
  end

  def BlogAPIHelper.raise_unimplemented
    BlogAPIHelper.raise_xmlrpc_exception(EXCEPTION_MESSAGE_UNIMPLEMENTED, EXCEPTION_CODE_UNIMPLEMENTED)
  end

  def BlogAPIHelper.raise_cant_find_websites_folder
    BlogAPIHelper.raise_xmlrpc_exception(EXCEPTION_CODE_CANT_FIND_WEBSITES_FOLDER, EXCEPTION_MESSAGE_CANT_FIND_WEBSITES_FOLDER)
  end

  def BlogAPIHelper.raise_xmlrpc_exception(message, code)
    raise XMLRPC::FaultException.new(message, code)
  end
end

module MetaWeblogCommand

  def MetaWeblogCommand.recent_posts(blog_id, number_of_posts)
    project_folder = BlogAPIHelper.project_folder_with_blog_id(blog_id)
    wildcat = Wildcat.new(project_folder, nil)
    posts = wildcat.website.blog.recent_posts(number_of_posts)
    posts.map { |post| BlogAPIHelper.hash_for_post(blog_id, post) }
  end

  def MetaWeblogCommand.get_post(post_id)
    post_specifier = PostSpecifier.new(post_id)
    BlogAPIHelper.hash_for_post(post_specifier.blog_id, post_specifier.post)
  end

  def MetaWeblogCommand.new_post(blog_id, struct)

  end

  def MetaWeblogCommand.edit_post(post_id, struct)

  end
end


# Old code for reference.
# class WeblogAPIUtilities
#
#   def self.splitPostID(postID)
#     postIDArray = postID.split(":")
#     blogID = postIDArray[0]
#     blogFolder = WeblogAPIUtilities.folderForBlogID(blogID)
#     website = Website.new(blogFolder, false)
#     filePath = blogFolder + postIDArray[1]
#     h = Hash.new()
#     h["blogID"] = blogID
#     h["blogFolder"] = blogFolder
#     h["website"] = website
#     h["filePath"] = filePath
#     return h
#   end
#
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
#
#   def self.addPost(website, h)
#     titleCopy = String.new(h["title"])
#     filename = ExportUtils.baseFilenameWithTitle(titleCopy)
#     filename += ".markdown"
#     postsFolder = website.projectSubfolder("posts/")
#     newPostFolder = postsFolder + ExportUtils.relativeFolderWithDate(Time.now())
#     filePath = newPostFolder + filename
#     rawText = rawTextWithStruct(h)
#     ExportUtils.writeFileToDisk(rawText, filePath)
#     return WeblogPost.new(website, filePath)
#   end
#
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
    BlogAPIHelper.check_auth(username, password)
    MetaWeblogCommand.recent_posts(blog_id, number_of_posts)
  end

  def getCategories(blog_id, username, password)
    # Wildcat doesn’t support categories, but this shouldn’t be seen as an error.
    BlogAPIHelper.check_auth(username, password)
    {}
  end

  def getPost(post_id, username, password)
    BlogAPIHelper.check_auth(username, password)
    MetaWeblogCommand.get_post(post_id)
  end

  def newPost(blog_id, username, password, struct, publish)
    # The publish parameter is ignored.
    BlogAPIHelper.check_auth(username, password)
    MetaWeblogCommand.new_post(blog_id, struct)
  end

  def editPost(post_id, username, password, struct, publish)
    # The publish parameter is ignored.
    BlogAPIHelper.check_auth(username, password)
    MetaWeblogCommand.edit_post(post_id, struct)
    return true
  end

  def newMediaObject(blog_id, username, password, struct)
    # Wildcat doesn’t support this yet.
    BlogAPIHelper.check_auth(username, password)
    BlogAPIHelper.raise_unimplemented
  end
end

s = XMLRPC::CGIServer.new()
s.add_handler("metaWeblog", MetaWeblogAPI.new())
s.serve()
