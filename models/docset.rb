# encoding: utf-8
class DocSet < Sequel::Model(:docsets)

  # Returns the url path for a given unformatted url
  def url_path(url)
    return link_map[build_key(url)]
  end

  def link_map
    return build_link_map({'.' => ''}, self.fs_path)
  end

  # Populates the given link_map and then returns it back to the caller
  def build_link_map(link_map, base_dir)
    relative_path = base_dir.sub(self.fs_path, '').sub(/^\//, '')
    Dir.foreach(base_dir) do |dir_item|
      # exclude . and _ files/directories
      if !dir_item.start_with?('.', '_')
        absolute_path = "#{base_dir}/#{dir_item}"
        if Dir.exist?(absolute_path)
          build_link_map(link_map, absolute_path + '/')
        end

        filepath = File::basename(absolute_path, File::extname(absolute_path))
        relative_filepath = relative_path + filepath
        link_map[build_key(relative_filepath)] = build_url(relative_filepath)
      end
    end

    return link_map
  end

  # Given a relative path to a file, build the correct key to @link_map
  def build_key(relative_path)
    # Currently assuming unique file names so the key should not build any directory
    # path information
    return File::basename(relative_path.gsub(/-/, ' ').downcase)
  end

  # Given a relative path to a file, builds the url to that file
  def build_url(relative_path)
    return relative_path.gsub(/\s/, '-').downcase
  end

end
