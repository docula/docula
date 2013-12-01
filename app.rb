require 'sinatra'
require 'sinatra/reloader'
require 'haml'
require 'redcarpet'
require 'grit'
require 'yaml'

require_relative 'minify_resources'

# We will load configuration from user specific files
$config = YAML.load_file('cfg/' + ENV['USER'] + '.yml')

class Docula < Sinatra::Application
  enable :sessions

  configure :production, :development do
    enable :logging
    set :haml, { :ugly => true }
  end

  configure :production do
    set :clean_trace, true
    set :show_exceptions, false

    # Minify is currently throwing an error due to the JS
    # code in this project.
    # set :css_files, :blob
    # set :js_files, :blob
    # MinifyResources.minify_all
    set :css_files, MinifyResources::CSS_FILES
    set :js_files, MinifyResources::JS_FILES
  end

  configure :development do
    set :css_files, MinifyResources::CSS_FILES
    set :js_files, MinifyResources::JS_FILES
  end

  set :public_folder, Proc.new { File.join(root, '/public/', $config['theme']) }
  set :views, Proc.new { File.join(root, '/views/', $config['theme']) }

  helpers do
    include Rack::Utils
    alias_method :h, :escape_html
  end
end

