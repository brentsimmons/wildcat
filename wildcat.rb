#!/usr/bin/env ruby -wU

require_relative 'model/website_settings'
require_relative 'model/website'

DEFAULT_SETTINGS_FILE_NAME = 'wildcat_settings'

class Wildcat

  attr_reader :website
  attr_reader :settings

  def initialize(project_folder, settings_file_name)
    @settings = Wildcat.settings_with_file_name(project_folder, settings_file_name)
    @website = Website.new(settings)
  end

  def build
    @website.build
    perform_rsync_if_needed
  end

  def Wildcat.settings_with_file_name(project_folder, file_name)
    if file_name.nil? || file_name.empty?
      file_name = DEFAULT_SETTINGS_FILE_NAME
    end
    settings_file_path = File.join(project_folder, file_name)
    WebsiteSettings.new(project_folder, settings_file_path)
  end

  private

  def perform_rsync_if_needed
    rsync_path = @settings.rsync_remote_path
    if rsync_path.nil? || rsync_path.empty? then return end
    WildcatUtils.rsync_remote(@settings.output_folder, rsync_path)
  end
end
