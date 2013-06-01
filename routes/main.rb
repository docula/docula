# encoding: utf-8

$config = YAML.load_file('properties.yml')

class Docula < Sinatra::Application

  get "/" do
    @title = "Welcome to Docula"
    repo = Grit::Repo.new($config['doc_repo_path'])
    tree = repo.commits.first.tree

    @tree = print_tree(tree, 0)

    haml :main
  end
  
  get '/:name/:branch' do
    docset = DocSet[:name => params[:name], :branch => params[:branch]]

    root = File.open(docset.fs_path)
    index = File.open(root.path + '/index.md')

    @md = DoculaMarkdown.render('test-path', index.read)

    root.close
    index.close

    haml :test
  end

  get '/render' do
    @title = 'Markdown Parsing Test'

    @md = DoculaMarkdown.render('md goes here')

    haml :test
  end

  get '/links' do
    @dirs = Links::build_tree($config['doc_repo_path'])

    haml :links
  end


end
