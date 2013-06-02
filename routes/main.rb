# encoding: utf-8

$config = YAML.load_file('properties.yml')

class Docula < Sinatra::Application

  get '/' do
    @title = 'Welcome to Docula'
    repo = Grit::Repo.new($config['doc_repo_path'])
    tree = repo.commits.first.tree

    @tree = print_tree(tree, 0)

    haml :main
  end

  # We will rely on the splat path matcher to support files that are in subdirectories
  ['/:name/:branch', '/:name/:branch/*'].each do |path|
    get path do
      name     = params[:name]
      branch   = params[:branch]
      url_path = params[:splat][0].to_s.chomp('/')

      docset = DocSet[:name => name, :branch => branch]

      absolute_path = docset.absolute_path(url_path)
      if Dir.exist?(absolute_path)
        absolute_path << '/index.md'
      end

      file = File.open(absolute_path)

      # Get markdown for the file
      @md = DoculaMarkdown.render(docset, file.read)

      # Get markdown for the sidebar
      @sidebar = docset.build_sidebar_md

      file.close

      haml :test
    end
  end

  get '/:name/:branch/links' do
    docset = DocSet[:name => params[:name], :branch => params[:branch]]
    @dirs = Links::build_tree(docset.fs_path)

    haml :links
  end


end
