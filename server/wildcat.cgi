#!/usr/bin/env ruby -wKU

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
require_relative '../utilities/wildcat_auth'
require_relative '../config.rb'

class MetaWeblogCommand

  METAWEBLOG_TITLE_KEY = 'title'
  METAWEBLOG_LINK_KEY = 'link'
  METAWEBLOG_POSTID_KEY = 'postid'
  METAWEBLOG_PERMALINK_KEY = 'permaLink'
  METAWEBLOG_DESCRIPTION_KEY = 'description'
  METAWEBLOG_DATE_CREATED_KEY = 'dateCreated'
  METAWEBLOG_DATE_MODIFIED_KEY = 'modDate'
  METAWEBLOG_ENCLOSURE_STRUCT_KEY = 'enclosure'
  METAWEBLOG_ENCLOSURE_LENGTH_KEY = 'length'
  METAWEBLOG_ENCLOSURE_TYPE_KEY = 'type'
  METAWEBLOG_ENCLOSURE_URL_KEY = 'url'

  EXCEPTION_MESSAGE_LOGIN_INVALID = 'Invalid login'
  EXCEPTION_CODE_LOGIN_INVALID = 0
  EXCEPTION_MESSAGE_CANT_FIND_WEBSITES_FOLDER = "Can't find websites folder"
  EXCEPTION_CODE_CANT_FIND_WEBSITES_FOLDER = 1
  EXCEPTION_MESSAGE_UNIMPLEMENTED = 'Unimplemented method'
  EXCEPTION_CODE_UNIMPLEMENTED = 2
  EXCEPTION_MESSAGE_CANT_FIND_POST = "Can't find post"
  EXCEPTION_CODE_CANT_FIND_POST = 3

  def initialize(username, password, blog_id)
    if !MetaWeblogCommand.authenticate(username, password)
      raise XMLRPC::FaultException.new(EXCEPTION_CODE_LOGIN_INVALID, EXCEPTION_MESSAGE_LOGIN_INVALID)
    end
    @blog_id = blog_id
		@wildcat = wildcat
  end

	def self.authenticate(username, password)
		stored_username = ENV[ENV_KEY_USERNAME]
		if stored_username.nil? || stored_username.empty? then return false end
		if stored_username != username then return false end

		hashed_password = ENV[ENV_KEY_HASHED_PASSWORD]
    WildcatAuth.verify_password(password, hashed_password)
	end

  # API

  def recent_posts(number_of_posts)
    posts = @wildcat.website.blog.recent_posts(number_of_posts)
    posts.map { |post| struct_for_post(post) }
  end

  def get_post(post_id)
    _, relative_path = MetaWeblogCommand.split_post_id(post_id)
    path = File.join(@wildcat.settings.posts_folder, relative_path)
    wildcat_file = WildcatFile.new(path)
    post = Post.new(@wildcat.settings, wildcat_file)
    struct_for_post(post)
  end

  def new_post(struct)
    title = struct[METAWEBLOG_TITLE_KEY]
    description = struct[METAWEBLOG_DESCRIPTION_KEY]
    file_name = file_name_for_new_post(title, description)
    relative_folder_path = relative_folder_path_with_date(Time.now)
    relative_path = File.join(relative_folder_path, file_name)
    path = File.join(@wildcat.settings.posts_folder, relative_path)
    text = post_text_with_struct(struct)
    WildcatUtils.write_file_if_different(path, text)
    new_post_id = post_id_with_relative_path(relative_path)

    rebuild_site
    
    new_post_id
  end

  def edit_post(post_id, struct)
    _, relative_path = MetaWeblogCommand.split_post_id(post_id)
    path = File.join(@wildcat.settings.posts_folder, relative_path)
    if !FileTest.exist?(path)
      raise XMLRPC::FaultException.new(EXCEPTION_CODE_CANT_FIND_POST, EXCEPTION_MESSAGE_CANT_FIND_POST)
    end

    wildcat_file = WildcatFile.new(path)
    existing_attributes = wildcat_file.attributes

    s = ''
    title = struct[METAWEBLOG_TITLE_KEY]
    s += att_line_unless_empty(TITLE_KEY, title)
    link = struct[METAWEBLOG_LINK_KEY]
    s += att_line_unless_empty(LINK_KEY, link)

    d = Time.now
    pub_date = existing_attributes[PUB_DATE_KEY]
    mod_date = struct.fetch(METAWEBLOG_DATE_MODIFIED_KEY, d)
    s += att_line(PUB_DATE_KEY, pub_date)
    s += att_line(MOD_DATE_KEY, mod_date)

    # Preserve existing attributes not specified in incoming struct.
    existing_attributes.each do |key, value|
      if key == TITLE_KEY || key == LINK_KEY || key == PUB_DATE_KEY || key == MOD_DATE_KEY then next end
      s += att_line(key, value)
    end

    s += struct[METAWEBLOG_DESCRIPTION_KEY].chomp

    WildcatUtils.write_file_if_different(path, s)

    rebuild_site
    
    true
  end

  def get_categories
    # Wildcat doesn’t support categories.
    []
  end

  def new_media_object(blog_id, struct)
    # TODO: support this.
    raise XMLRPC::FaultException.new(EXCEPTION_CODE_UNIMPLEMENTED, EXCEPTION_MESSAGE_UNIMPLEMENTED)
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

  def struct_for_post(post)
    h = {}
    h[METAWEBLOG_POSTID_KEY] = create_post_id(post)
    h[METAWEBLOG_DESCRIPTION_KEY] = post.source_text
    h[METAWEBLOG_DATE_CREATED_KEY] = post.pub_date
    h[METAWEBLOG_PERMALINK_KEY] = post.permalink
    h[METAWEBLOG_DATE_MODIFIED_KEY] = post.mod_date unless post.mod_date.nil?
    h[METAWEBLOG_TITLE_KEY] = post.title unless post.title.nil? || post.title.empty?
    h[METAWEBLOG_LINK_KEY] = post.external_url unless post.external_url.nil? || post.external_url.empty?
    # TODO: enclosures
    h
  end

  def wildcat
    if @blog_id.nil? || @blog_id.empty? || @blog_id.include?('..')
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
    raise XMLRPC::FaultException.new(EXCEPTION_CODE_CANT_FIND_WEBSITES_FOLDER, EXCEPTION_MESSAGE_CANT_FIND_WEBSITES_FOLDER)
  end

  def file_name_for_new_post(title, description)
    file_name = title
    if file_name.nil? || file_name.empty?
      file_name = description
    end

    file_name = file_name.dup
    file_name.chomp!
    file_name.downcase!
    file_name.gsub!(' ', '_')
    file_name.gsub!(/\W/, '_')
    while file_name.include?('__')
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

  def post_text_with_struct(struct)
    s = ''

    title = struct[METAWEBLOG_TITLE_KEY]
    s += att_line_unless_empty(TITLE_KEY, title)
    link = struct[METAWEBLOG_LINK_KEY]
    s += att_line_unless_empty(LINK_KEY, link)

    d = Time.now
    pub_date = struct.fetch(METAWEBLOG_DATE_CREATED_KEY, d)
    mod_date = struct.fetch(METAWEBLOG_DATE_MODIFIED_KEY, d)
    s += att_line(PUB_DATE_KEY, pub_date)
    s += att_line(MOD_DATE_KEY, mod_date)

    s += struct[METAWEBLOG_DESCRIPTION_KEY].chomp
    return s
  end

  def att_line(key, value)
		"@#{key} #{value}\n"
  end

  def att_line_unless_empty(key, value)
  	if value.nil? || value.empty? then return '' end
  	att_line(key, value)
  end

  def rebuild_site
  	pid = Process.fork
  	if pid.nil? then
  		@wildcat.build
  	else
  		Process.detach(pid)
  	end
  end
end

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
    blog_id, _ = MetaWeblogCommand.split_post_id(post_id)
    command = MetaWeblogCommand.new(username, password, blog_id)
    command.get_post(post_id)
  end

  def newPost(blog_id, username, password, struct, publish)
    # The publish parameter is ignored.
    command = MetaWeblogCommand.new(username, password, blog_id)
    command.new_post(struct)
  end

  def editPost(post_id, username, password, struct, publish)
    # The publish parameter is ignored.
    blog_id, _ = MetaWeblogCommand.split_post_id(post_id)
    command = MetaWeblogCommand.new(username, password, blog_id)
    command.edit_post(post_id, struct)
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
