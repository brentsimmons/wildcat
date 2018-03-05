require 'fileutils'

module WildcatUtils

  def WildcatUtils.write_file_if_different(path, text)

    # Make sure the folder exists.
    # Skip writing the file if existing file has the same text.

    FileUtils.mkdir_p(File.dirname(path))

    should_write_file = !FileTest.exist?(path) || !WildcatUtils.file_equals_string?(path, text)
    if !should_write_file then return end

    puts("Writing #{path}")
    write_text_file(path, text)
  end

  def WildcatUtils.write_text_file(path, text)
    f = File.open(path, 'w')
    f.puts(text)
    f.close()
  end

  def WildcatUtils.read_text_file(path)
		file = File.open(f, 'r')
		text = file.read()
		file.close()
		text
  end

  def WildcatUtils.file_equals_string?(path, text)
    file_text = WildcatUtils.read_text_file(path)
    file_text.strip == text.strip
  end

  def WildcatUtils.files_in_folder(folder)

    # Doesn’t look in folders that start with a . character.

    paths = []

    Find.find(folder) do |f|
      if File.basename(f)[0] == ?.
        Find.prune
      end
      if !FileTest.directory?(f)
        paths << f
      end
    end

    paths
  end

end
