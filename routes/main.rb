class Docula < Sinatra::Application

  before do
    cache_control :no_cache, :max_age => 0
    cache_control :no_cache, :no_store, :must_revalidate, :max_age => 0
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

      file_mimetype = DoculaFile::detect_mime_type(absolute_path)

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
end
