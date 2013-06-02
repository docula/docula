# encoding: utf-8
class DocSet < Sequel::Model(:docsets)

  @name = nil
  @branch = nil
  @fs_path = nil

  def after_initialize
    @docname_url_map = {'.' => ''}
    @url_fs_map = {}
    build_lookup_maps(self.fs_path)
  end

  # Returns a String with the full indented markdown-formatted sidebar for this entire
  # docset
  def build_sidebar_md
    build_sidebar_md_helper(self.fs_path, 0)
  end

  def build_sidebar_md_helper(base_dir, level)
    result = ''
    File.open(base_dir + '/_sidebar.md', 'r').each_line do |line|
      # For each line, determine if it is a subdirectory or not
      # and then build each sidebar for each subdirectory
      line.gsub!(/-.*\[{2}(.*)\]{2}/) { |s|
        # build the sidebar text for the current item
        result += ' ' * (4 * level) + s + "\n"

        #if the current item is a directory, build the sidebar for that directory
        docname = $1.split('|')[0].strip.downcase
        path = @url_fs_map[@docname_url_map[docname]]
        if Dir.exist?(path)
          result += build_sidebar_md_helper(path, level + 1)
        end

      }
    end

    return result
  end

  # Returns the url path for a given unformatted url
  def url_path(docname)
    @docname_url_map[docname.downcase]
  end

  def full_url(docname)
    if (url_path(docname))
      self.name + '/' + self.branch + '/' + url_path(docname)
    else
      nil
    end
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
      if !dir_item.start_with?('.', '_')
        absolute_path = "#{base_dir}/#{dir_item}"
        if Dir.exist?(absolute_path)
          build_lookup_maps(absolute_path + '/')
        end

        #Build the URL which should be the relative path to the file minus the file extension
        file_ext = File::extname(absolute_path)
        filepath = File::basename(absolute_path, File::extname(absolute_path))
        relative_filepath = relative_path + filepath
        url = build_url(relative_filepath)
        @docname_url_map[build_key(relative_filepath)] = url

        @url_fs_map[url] = absolute_path + file_ext
      end
    end
  end

  # Given a relative path to a file, build the correct key to @docname_url_map
  def build_key(relative_path)
    # Currently assuming unique file names so the key should not build any directory
    # path information
    File::basename(relative_path.gsub(/-/, ' ').downcase)
  end

  # Given a relative path to a file, builds the url to that file
  def build_url(relative_path)
    relative_path.gsub(/\s/, '-').downcase
  end

end
