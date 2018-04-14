require_relative 'renderer'
require_relative '../model/website_settings'

module PageBuilder

  def PageBuilder.build(settings, template_name, context, destination_path)
    renderer = Renderer.new(settings, template_name, context)
    WildcatUtils.write_file_if_different(destination_path, renderer.to_s)
  end
end
