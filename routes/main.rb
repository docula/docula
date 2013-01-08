# encoding: utf-8
class MyApp < Sinatra::Application
    get "/" do
        @title = "Welcome to MyApp 3"               
        haml :main
    end
end
