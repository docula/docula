# encoding: utf-8
class Docula < Sinatra::Application

  get '/' do
    @title = 'Welcome to Docula'

    repo = Grit::Repo.new('/Users/Andre/GitHub/docula-sample/')
    tree = repo.commits.first.tree

    @tree = print_tree(tree, 0)

    haml :main
  end

  get '/render' do
    @title = 'Markdown Parsing Test'

    @md = DoculaMarkdown.render('md goes here')

    haml :test
  end

end
