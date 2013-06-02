class DocSet < Sequel::Model(:docsets)
  # Database persisted properties
  @name = nil
  @branch = nil
  @fs_path = nil

  def after_initialize
    @docname_url_map = {'.' => ''}
    @url_fs_map = {'' => self.fs_path}

    build_lookup_maps(self.fs_path)
  end

  # Returns a String with the full indented markdown-formatted
  # sidebar for this entire docset
  def sidebar_md
    build_sidebar_md(self.fs_path, 0)
  end

  def build_sidebar_md(base_dir, level)
    result = ''

    File.open(base_dir + '/_sidebar.md', 'r').each_line do |line|
      line.gsub!(/-.*\[{2}(.*)\]{2}/) { |s|
        # Build the sidebar text for the current item
        result += (' ' * (4 * level)) + s + "\n"

        # If the current item is a directory, build the sidebar for that directory
        docname = $1.split('|')[0].strip.downcase
        path = @url_fs_map[@docname_url_map[docname]]
        unless docname == '.'
          if Dir.exist?(path)
            result += build_sidebar_md(path, level + 1)
          end
        end
      }
    end

    result
  end

  # Returns the absolute file system path for the given url fragment
  def absolute_path(url)
    @url_fs_map[url].chomp('/') unless @url_fs_map[url].nil?
  end

  # Returns the url path for the given document name
  def url_path(docname)
    key = docname.downcase
    @docname_url_map[key].chomp('/') unless @docname_url_map[key].nil?
  end

  # Returns the full url for the given document name
  def full_url(docname)
    url = url_path(docname)
    '/' + [self.name, self.branch, url].join('/') if url
  end

  # Assuming that markdown links look like this:
  #   [[ Some File Name | other display name]]
  # the link map that is returned is keyed by the the left-hand side of the pipe, lowercase.
  # So if 'Some File Name' is actually in subdirectory 'Directory-One', then the returned map will be
  #   { 'some file name' => directory-one/some-file-name
  #
  # This also allows linking to the root directory by using '.', like:
  #   [[ . | Home]]

  # Populates the given docname_url_map and then returns it back to the caller
  def build_lookup_maps(base_dir)
    relative_path = base_dir.sub(self.fs_path, '').sub(/^\//, '')
    Dir.foreach(base_dir) do |dir_item|
      # exclude . and _ files/directories
      unless dir_item.start_with?('.', '_')
        absolute_path = "#{base_dir}/#{dir_item}"
        if Dir.exist?(absolute_path)
          build_lookup_maps(absolute_path + '/')
        end

        #Build the URL which should be the relative path to the file minus the file extension
        filepath = File::basename(absolute_path, File::extname(absolute_path))
        relative_filepath = relative_path + filepath
        url = build_url(relative_filepath)
        @docname_url_map[build_docname_key(relative_filepath)] = url

        @url_fs_map[url] = absolute_path.squeeze('/')
      end
    end
  end

  # Given a relative path to a file, build the correct key for @docname_url_map
  # Note: Currently assumes that document names are unique per document set
  def build_docname_key(relative_path)
    File::basename(relative_path.gsub(/-/, ' ').downcase)
  end

  # Given a relative path to a file, builds the url to that file
  def build_url(relative_path)
    relative_path.gsub(/\s/, '-').downcase
  end
end
