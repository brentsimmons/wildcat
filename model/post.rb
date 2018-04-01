require_relative '../wildcat_constants'
require_relative '../utilities/wildcat_file'
require_relative 'enclosure'

class Post

  attr_reader :title
  attr_reader :content_html
  attr_reader :source_text
  attr_reader :permalink
  attr_reader :external_url
  attr_reader :pub_date
  attr_reader :enclosure
  attr_reader :destination_path # path to permalink version

  def initialize(settings, wildcat_file)
    @settings = settings
    @source_path = wildcat_file.path
    @source_text = wildcat_file.text
    @destination_path, @permalink = WildcatUtils.paths(@source_path, @settings.posts_folder, @settings.blog_output_folder, @settings.site_url, @settings.output_file_suffix)
    @attributes = wildcat_file.attributes
    @external_url = @attributes[LINK_KEY]
    @title = @attributes[TITLE_KEY]

    @content_html = wildcat_file.to_html
    if !@content_html.start_with?('<p>')
    	@content_html = '<p>' + content_html
    end

    @pub_date = @attributes[PUB_DATE_KEY]
    @rendered_html_including_link = nil
    @rendered_html = nil

    enclosure_url = @attributes[ENCLOSURE_URL_KEY]
    if !enclosure_url.nil? && !enclosure_url.empty?
      @enclosure = Enclosure(@attributes)
    else
      @enclosure = nil
    end

  end

  def to_json_feed_component

    json = {}

    add_if_not_empty(json, JSON_FEED_TITLE_KEY, @title)

    date_string = @pub_date.iso8601
    json[JSON_FEED_PUB_DATE_KEY] = date_string

    json[JSON_FEED_ID_KEY] = @permalink
    json[JSON_FEED_URL_KEY] = @permalink

    add_if_not_empty(json, JSON_FEED_EXTERNAL_URL_KEY, @external_url)

    json[JSON_FEED_CONTENT_HTML_KEY] = @content_html

    if !@enclosure.nil?
      enclosure_json = @enclosure.to_json_feed_component
      json[JSON_FEED_ATTACHMENTS_KEY] = [enclosure_json]
    end

    json
  end

  def to_html(including_link)

    # Render post.
    # If including_link is true, then this is for the home page or other multi-post page.
    # If including_link is false, then this is the single-post-on-a-page version. Where the permalink points to.

    if including_link
      if @rendered_html_including_link then return @rendered_html_including_link end
    else
      if @rendered_html then return @rendered_html end
    end

    template_name = template_name(including_link)

    s = render_with_template(template_name)
    if including_link
      @rendered_html_including_link = s
    else
      @rendered_html = s
    end

    s
  end


  private

  def add_if_not_empty(json, key, value)
    json[key] = value unless (!value || value.empty?)
  end

  def template_name(including_link)

    # A post may not have a title. There are four possible templates:
    # post
    # post_including_link
    # post_no_title
    # post_including_link_no_title

    template_name = 'post'

    if including_link then template_name += '_including_link' end
    if @title.nil? || @title.empty? then template_name += '_no_title' end

    template_name
  end

  def context

    context = {}

    context[CONTEXT_PERMALINK_KEY] = @permalink
    context[CONTEXT_EXTERNAL_URL_KEY] = @external_url

    if !@external_url.nil?
      context[CONTEXT_LINK_PREFERRING_EXTERNAL_URL_KEY] = @external_url
    else
      context[CONTEXT_LINK_PREFERRING_EXTERNAL_URL_KEY] = @permalink
    end

    context[CONTEXT_TITLE_KEY] = @title
    context[CONTEXT_CONTENT_HTML_KEY] = @content_html
    context[CONTEXT_PUB_DATE_KEY] = @pub_date
    context[CONTEXT_DISPLAY_DATE_KEY] = @pub_date.strftime("%d %b %Y")

    context
  end

  def render_with_template(template_name)

    renderer = Renderer.new(@settings, template_name, context)
    renderer.to_html + "\n"
  end
end
