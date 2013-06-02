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
  get '/:name/:branch/*' do
    name      = params[:name]
    branch    = params[:branch]
    file_path = params[:splat][0].to_s.chomp('/')

    # If file_path is empty at this stage, we are looking for the root index.md file
    if file_path.empty?
      file_path = 'index'
    end

    docset = DocSet[:name => name, :branch => branch]
    doc_root = docset.fs_path << '/' unless docset.fs_path.end_with?('/')

    # Attempt to load the current file. If it's not found, assume it's a directory and try again.
    begin
      file = File.open(doc_root + file_path + '.md')
    rescue
      file = File.open(doc_root + file_path + '/index.md')
    end

    # Get markdown for the file
    @md = DoculaMarkdown.render(docset, file.read)

    file.close

    haml :test
  end

  get '/:name/:branch/links' do
    docset = DocSet[:name => params[:name], :branch => params[:branch]]
    @dirs = Links::build_tree(docset.fs_path)

    haml :links
  end


end
