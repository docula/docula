class Docula < Sinatra::Application

  # We will rely on the splat path matcher to support files that are in subdirectories
  %w(/:name/:branch /:name/:branch/*.*).each do |path|
    get path do
      name     = params[:name]
      branch   = params[:branch]
      url_path = params[:splat][0].to_s.chomp('/')
      extension = params[:splat][1]

      docset = DocSet[:name => name, :branch => branch]

      # If the absolute filesystem path for this url is a directory,
      # we want to render the index.md file in that directory.
      absolute_path = docset.absolute_path(url_path)
      if Dir.exist?(absolute_path)
        absolute_path << '/index.md'
      end

      File.open(absolute_path) do |file|
        @md = file.read
        @html = DoculaMarkdown.render(docset, @md)
        @sidebar = DoculaMarkdown.render_sidebar(docset)
      end

      if extension == 'raw'
        @md
      elsif extension == 'html'
        @html
      else
        haml :page, :layout => !request.xhr?
      end
    end
  end

end
