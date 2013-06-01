# encoding: utf-8
class MyApp < Sinatra::Application

  get "/" do
    @title = "Welcome to MyApp 3"

    repo = Grit::Repo.new("/Users/Andre/GitHub/docula/tmp/repo/")
    tree = repo.commits.first.tree

    @tree = print_tree(tree, 0)

    haml :main
  end

end
