require 'fileutils'
require 'find'
require 'open3'
require_relative '../wildcat_constants'

module WildcatUtils
  def self.write_file_if_different(path, text)
    # Make sure the folder exists.
    # Skip writing the file if existing file has the same text.

    FileUtils.mkdir_p(File.dirname(path))

    should_write_file = !FileTest.exist?(path) || !WildcatUtils.file_equals_string?(path, text)
    return unless should_write_file

    print_to_console("Writing #{path}")
    write_text_file(path, text)
  end

  def self.write_text_file(path, text)
    f = File.open(path, 'w:UTF-8')
    f.puts(text)
    f.close
  end

  def self.read_text_file(path)
    file = File.open(path, 'r:UTF-8')
    text = file.read
    file.close
    text
  end

  def self.file_equals_string?(path, text)
    file_text = WildcatUtils.read_text_file(path)
    file_text.strip == text.strip
  end

  def self.rsync_local(source, dest)
    FileUtils.mkdir_p(File.dirname(dest))
    Open3.popen3('rsync', '-azu', source, dest)[1].read
  end

  def self.rsync_remote(source, dest)
    print_to_console("Syncing to #{dest}")
    Open3.popen3('rsync', '-avzu', source, dest)[1].read
  end

  def self.files_in_folder(folder)
    # Doesn’t look in folders that start with a . character.

    paths = []

    Find.find(folder) do |f|
      Find.prune if File.basename(f)[0] == '.'
      paths << f unless FileTest.directory?(f)
    end

    paths
  end

  def self.file_is_text_source_file?(path)
    path.end_with?(MARKDOWN_SUFFIX, HTML_SUFFIX)
  end

  def self.text_source_files_in_folder(folder)
    file_paths = files_in_folder(folder)
    file_paths.select { |path| file_is_text_source_file?(path) }
  end

  def self.paths(path, input_folder, output_folder, site_url, output_file_suffix)
    # Return destination file path *and* permalink.

    relative_path = path.dup
    relative_path[0, input_folder.length] = '' # Strip source folder path.

    destination_path = File.join(output_folder, relative_path)
    destination_path = change_source_suffix_to_output_suffix(destination_path, output_file_suffix)

    permalink = File.join(site_url, relative_path)
    permalink = change_source_suffix_to_output_suffix(permalink, output_file_suffix)

    [destination_path, permalink, relative_path]
  end

  def self.change_source_suffix_to_output_suffix(path, output_suffix)
    # output_suffix should start with a . or be empty.
    # Only chops off .html and .markdown suffixes.

    path_array = path.split('.')
    if path_array.last == MARKDOWN_NO_LEADING_DOT || path_array.last == HTML_NO_LEADING_DOT
      path_array.delete_at(path_array.length - 1)
      updated_path = path_array.join('.')
      return updated_path + output_suffix
    end

    path + output_suffix
  end

  def self.add_suffix_if_needed(path, suffix)
    return path if suffix.nil? || suffix.empty?
    path + suffix
  end

  def self.running_as_server
    is_server_string = ENV.fetch(ENV_KEY_RUNNING_AS_SERVER, '')
    is_server_string == 'true'
  end

  def self.print_to_console(message)
    puts(message) unless running_as_server
  end
end
