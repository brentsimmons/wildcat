#!/usr/bin/env ruby -wU

require_relative 'model/website_settings'
require_relative 'model/website'

DEFAULT_SETTINGS_FILE_NAME = 'wildcat_settings'.freeze

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

  def self.settings_with_file_name(project_folder, file_name)
    file_name = DEFAULT_SETTINGS_FILE_NAME if file_name.nil? || file_name.empty?
    settings_file_path = File.join(project_folder, file_name)
    WebsiteSettings.new(project_folder, settings_file_path)
  end

  private

    def perform_rsync_if_needed
      rsync_path = @settings.rsync_remote_path
      return if rsync_path.nil? || rsync_path.empty?
      WildcatUtils.rsync_remote(@settings.output_folder, rsync_path)
    end
end
