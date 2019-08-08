require_relative '../utilities/wildcat_utils'
require_relative '../renderer/renderer'

class Page

  def self.build_all_pages(settings)
    pages = all_pages(settings)
    pages.each { |page| page.build }
  end

  def build
    WildcatUtils.write_file_if_different(@output_path, to_html)
  end

  private

  def self.all_pages(settings)
    paths = WildcatUtils.text_source_files_in_folder(settings.pages_folder)
    paths.map { |path| Page.new(settings, WildcatFile.new(path)) }
  end

  def initialize(settings, wildcat_file)
    @path = wildcat_file.path
    @settings = settings
    @output_path, @permalink, _ = WildcatUtils.paths(@path, settings.pages_folder, settings.output_folder, settings.site_url, settings.output_file_suffix)
    @content_html = wildcat_file.to_html
    @title = wildcat_file.attributes[TITLE_KEY]
    @show_title = wildcat_file.attributes[TITLE_SHOW_KEY]
    @template_name = wildcat_file.attributes[TEMPLATE_NAME_KEY]
    @pub_date = wildcat_file.attributes[PUB_DATE_KEY]
  end

  def context

    context = {}

    context[CONTEXT_PERMALINK_KEY] = @permalink
    context[CONTEXT_TITLE_KEY] = @title
    context[CONTEXT_CONTENT_HTML_KEY] = @content_html

    if !@pub_date.nil?
      context[CONTEXT_DISPLAY_DATE_KEY] = @pub_date.strftime("%d %b %Y")
    end

    context
  end

  def to_html
  	template_name = 'page'
  	if !@show_title.nil? && !@show_title
  		template_name = 'page_no_title'
  	end
  	if !@template_name.nil?
  		template_name = @template_name
  	end
		renderer = Renderer.new(@settings, template_name, context)
    renderer.to_s
  end
end
