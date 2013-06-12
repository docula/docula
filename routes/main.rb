class Docula < Sinatra::Application

  # We will rely on the splat path matcher to support files that are in subdirectories
  %w(/:name/:branch /:name/:branch/*).each do |path|
    get path do
      name     = params[:name]
      branch   = params[:branch]
      url_path = params[:splat][0].to_s.chomp('/')

      docset = DocSet[:name => name, :branch => branch]

      # If the absolute filesystem path for this url is a directory,
      # we want to render the index.md file in that directory.
      absolute_path = docset.absolute_path(url_path)
      if Dir.exist?(absolute_path)
        absolute_path << '/_index.md'
      end

      file_mimetype = DoculaFile::detect_mime_type(absolute_path)
      File.open(absolute_path) do |file|
        @raw = file.read
        # Only attempt to render text files
        @html = DoculaMarkdown.render(docset, @raw) if file_mimetype.include? 'text'
        @sidebar = DoculaMarkdown.render_sidebar(docset)
      end

      if absolute_path.end_with?('.md')
        haml :page, :layout => !request.xhr?
      else
        content_type file_mimetype
        @raw
      end
    end
  end

end
