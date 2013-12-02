class Docula < Sinatra::Application

  before do
    cache_control :no_cache, :max_age => 0
    cache_control :no_cache, :no_store, :must_revalidate, :max_age => 0
  end

  get '/test' do
      'ok'
  end

  # We will rely on the splat path matcher to support files that are in subdirectories
  %w(/:name/:branch /:name/:branch/*).each do |path|
    get path do
      name     = params[:name]
      branch   = params[:branch]
      url_path = params[:splat][0].to_s.chomp('/')
      format   = params[:format]

      # Loop through all known repositories for the given name and establish
      # the sidebar for available versions as well as determine which version
      # should be served.
      docset = nil
      @branches = Hash.new()
      DocSet.where(:name => name).each { |ds|
        branch_id = ds.branch
        if ds.is_current
          if branch == 'current'
            docset = ds
          end
          branch_id = 'current'
          branch_name = "Current Version (#{ds.branch})"
        else
          if branch == ds.branch
            docset = ds
          end
          branch_name = ds.branch
        end
        @branches[branch_id] = branch_name
      }

      # If the absolute filesystem path for this url is a directory,
      # we want to render the index.md file in that directory.
      absolute_path = docset.absolute_path(url_path)
      if Dir.exist?(absolute_path)
        absolute_path << '/_index.md'
      end

      logger.info 'Loading file: ' + absolute_path

      file_mimetype = DoculaFile::detect_mime_type(absolute_path) if File.exist?(absolute_path)

      if format == 'raw' or !absolute_path.end_with?('.md')
        content_type file_mimetype
        send_file absolute_path,
                  :type => file_mimetype,
                  :disposition => 'inline'
      else
        File.open(absolute_path) do |file|
          @raw = file.read
          # Only attempt to render text files
          @html = DoculaMarkdown.render(docset, @raw) if file_mimetype.include? 'text'
          @sidebar = DoculaMarkdown.render_sidebar(docset)
        end

        haml :page, :layout => !request.xhr?
      end
    end
  end

  %w(/:name/:branch/save /:name/:branch/*/save).each do |path|
    post path do
      name = params[:name]
      branch = params[:branch]
      url_path = params[:splat][0].to_s.chomp('/')

      docset = DocSet.get name, branch

      absolute_path = docset.absolute_path(url_path)
      if Dir.exist?(absolute_path)
        absolute_path << '/_index.md'
      end
      logger.info 'Saving data for ' + absolute_path

      user = params[:user]
      email = params[:email]
      message = params[:message]
      content = params[:content]

      # TODO: Handle cases where 2 people attempt to commit to the same file at the same time
      # TODO: Prevent empty commits when the files have the exact same content
      # TODO: Handle cases to commit on different branch AND local, checked-out branch. Current
      # version yields weird results with

      # Instantiate the new Rugged repository based on where it lives in the file system
      repo = Rugged::Repository.new(docset.fs_path)
      # Grab the Rugged-typed branch for the text-based branch in the database
      rugged_branch = Rugged::Branch.lookup(repo, docset.branch)
      # Get the top commit from that branch
      topmost_commit = repo.lookup(rugged_branch.tip.oid)

      # Create a temporary file to write the new contents to. Creating a blob based on just contents
      # has been problematic in terms of newlines. This manifests itself as the appearance of the entire
      # file being overwritten when really on a few lines are actually different
      tmp_location = "#{absolute_path}.tmp"
      File.open(tmp_location, 'w') { |file|
        file.write content
      }
      # Create a new blob hash in the repository with the contents of the temporary file
      oid = Rugged::Blob.from_disk(repo, tmp_location)

      updated_tree = nil
      # Deal with indexes if the branch is actually checked out
      if rugged_branch.tip.oid == repo.head.target
        index = repo.index
        # Read the active commit's tree into the index
        index.read_tree(topmost_commit.tree)
        index.add(:path => docset.relative_path(absolute_path), :oid => oid, :filemode => 0100644)
        index.write
        updated_tree = index.write_tree(repo)
      else
        # If we are not attempting to write to a currently checked-out branch, then write directly to
        # that branch's tree and do not screw with the index at all
        # Based on the tree from the topmost commit, create a new tree builder to write this blob to
        treebuilder = Rugged::Tree::Builder.new(topmost_commit.tree)
        # TODO: get the correct file mode based on the file itself
        # TODO: Using the relative path will not work with file names in subdirectories; need to recurse through the trees
        treebuilder << { :type => :blob, :name => docset.relative_path(absolute_path), :oid => oid, :filemode => 0100644 }
        updated_tree = treebuilder.write(repo)
      end

      # Create the options for the new commit we're about to write
      options = {}
      # Write out the SHA of this modified tree
      options[:tree] = updated_tree
      options[:author] = { :name => user, :email => email, :time => Time.now }
      options[:committer] = { :name => user, :email => email, :time => Time.now }
      options[:message] ||= message
      # Parent should be the top commit of the editing branch
      options[:parents] = repo.empty? ? [] : [ topmost_commit.oid ].compact
      # The ref cannot be something like 'master' it needs to be 'refs/heads/master'
      options[:update_ref] = rugged_branch.canonical_name

      # Actually write the commit to the repository
      Rugged::Commit.create(repo, options)

      # Delete the temporary file
      File.delete(tmp_location)

      if rugged_branch.tip.oid == repo.head.target
        # Update the index to the latest tree that was just committed
        index = repo.index
        index.read_tree(repo.lookup(updated_tree))
        index.write

        # Write to the actual file since this is checked out on the filesystem
        File.open(absolute_path, 'w') { |file|
          file.write content
        }
      end

      # Render the new content to return
      @html = DoculaMarkdown.render(docset, content)
      haml :page, :layout => !request.xhr?
    end
  end

end