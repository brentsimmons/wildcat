#!/usr/bin/env ruby -wU

require_relative 'wildcat'

# Command-line
# Assumes the current directory is inside the top level of the website project folder.
# Call it like this:
# ruby /path/to/wildcat_publish.rb
#
# Default settings file is wildcat_settings.
# To do a preview (for instance) instead, specify a separate settings file, as in:
# ruby wildcat_publish.rb --settings preview_settings
#
# Tip: create an alias for your shell to shorten things.
# For instance, I use pi — “Publish Inessential” — as an alias like this:
# pushd "/Users/brent/path/to/inessential.com";ruby wildcat_publish.rb;popd

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
