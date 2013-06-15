class DocSet < Sequel::Model(:docsets)

  DocSet.plugin :after_initialize

  # Database persisted properties
  @name = nil
  @branch = nil
  @fs_path = nil

  def after_initialize
    @docname_url_map = {'.' => ''}
    if (self.respond_to? 'fs_path')
      @url_fs_map = {'' => self.fs_path}

      build_lookup_maps(self.fs_path)
    end
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
        docname = $1.downcase.strip
        if docname.include?('|')
          docname = docname.split('|')[1].strip
        end

        path = @url_fs_map[@docname_url_map[docname]]

        unless docname == '.'
          if Dir.exist?(path)
            result << build_sidebar_md(path, level + 1)
          end
        end
      }
    end

    result
  end

  # Returns the absolute file system path for the given url fragment
  def absolute_path(url)
    return @url_fs_map[url].chomp('/') unless @url_fs_map[url].nil?
    self.fs_path + '/' + url unless url.nil?
  end

  # Returns the url path for the given document name
  def url_path(docname)
    key = docname.downcase
    @docname_url_map[key].chomp('/') unless @docname_url_map[key].nil?
  end

  # Returns the full url for the given document name. This includes the url path prepended
  # with the docset name, branch, and a leading '/'.
  def full_url(docname)
    url = url_path(docname)
    full_url_from_path(url)
  end

  # Returns the full url for the given url path by prepending the docset_url
  # followed by the given url_path. The given url_path
  # can have a leading slash or not; this function will still work fine
  def full_url_from_path(url_path)
    [self.docset_url, url_path.sub(/^\//, '')].join('/') if url_path
  end

  # Returns the url for this docset with the beginning slash for use as an absolute URL
  def docset_url
    '/' + [self.name, self.branch].join('/')
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
    Dir.foreach(base_dir) do |dir_item|
      # exclude . and _ files/directories
      unless dir_item.start_with?('.', '_')
        absolute_path = "#{base_dir}/#{dir_item}"
        filename = File::basename(absolute_path)

        if Dir.exist?(absolute_path)
          build_lookup_maps(absolute_path)
        else
          filename = File::basename(absolute_path, File::extname(absolute_path))
        end

        url = build_url("#{base_dir}/#{filename}")
        @url_fs_map[url] = absolute_path

        docname = build_docname_key(filename)
        @docname_url_map[docname] = url
      end
    end
  end

  # Given a relative path to a file, build the correct key for @docname_url_map
  # Note: Currently assumes that document names are unique per document set
  def build_docname_key(relative_path)
    File::basename(relative_path.gsub(/-/, ' ').downcase)
  end

  # Given an absolute path to a file without the extension, builds the url to that file
  # Assuming an absolute path equal to '/Users/Andre/docula-sample/Dir-One/File-Two',
  # and self.fs_path equal to '/Users/Andre/docula-sample', returns '/dir-one/file-two'
  def build_url(absolute_path)
    absolute_path.gsub(self.fs_path, '').gsub(/^\//, '').downcase
  end
end
