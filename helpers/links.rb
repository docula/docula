module Links

  @link_map = {'.' => ''}

  # Builds the link tree based on a given absolute directory path
  def self.build_tree(base_dir)
    relative_path = base_dir.sub($config['doc_repo_path'], '').sub(/^\//, '')
    Dir.foreach(base_dir) do |dir_item|
      # exclude . and _ files/directories
      if !dir_item.start_with?('.', '_')
        absolute_path = "#{base_dir}/#{dir_item}"
        if Dir.exist?(absolute_path)
          build_tree(absolute_path + '/')
        end

        filepath = File::basename(absolute_path, File::extname(absolute_path))
        relative_filepath = relative_path + filepath
        @link_map[build_key(relative_filepath)] = build_url_path(relative_filepath)
      end

    end

    return @link_map
  end

  def self.build_key(relative_path)
    return relative_path.gsub(/-/, ' ').downcase
  end

  def self.build_url_path(relative_path)
    return relative_path.gsub(/\s/, '-').downcase
  end

end