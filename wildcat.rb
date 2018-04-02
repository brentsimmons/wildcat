#!/usr/bin/env ruby -wU

require_relative 'model/website_settings'
require_relative 'model/website'
require_relative 'utilities/wildcat_utils'

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
    if settings_file_name.nil? || settings_file_name.empty?
      settings_file_name = DEFAULT_SETTINGS_FILE_NAME
    end
    settings_file_path = File.join(project_folder, settings_file_name)
    WebsiteSettings.new(project_folder, settings_file_path)
  end

  private

  def perform_rsync_if_needed
    rsync_path = @settings.rsync_remote_path
    if rsync_path.nil? || rsync_path.empty? then return end
    puts "Syncing to #{rsync_path}"
    WildcatUtils.rsync_remote(@settings.output_folder, rsync_path)
  end
end

# Command-line
# Assumes the current directory is inside the top level of the website project folder.
# Call it like this:
# ruby /path/to/wildcat.rb
#
# Default settings file is wildcat_settings.
# To do a preview (for instance) instead, specify a separate settings file, as in:
# ruby wildcat.rb --settings preview_settings
#
# Tip: create an alias for your shell to shorten things.
# For instance, I use pi — “Publish Inessential” — as an alias like this:
# pushd "/Users/brent/path/to/inessential.com";ruby wildcat.rb;popd

settings_file = nil
next_argument_is_settings = false
found_alternate_settings_file = false

ARGV.each do |arg|
  if next_argument_is_settings && !found_alternate_settings_file
    settings_file = arg
    found_alternate_settings_file = true
  end
  if arg == '--settings' && !found_alternate_settings_file
    next_argument_is_settings = true
  end
end

folder = Dir.pwd
wildcat = Wildcat.new(folder, settings_file)
wildcat.build
