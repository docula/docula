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

  configure :production do
    set :haml, { :ugly => true }
    set :clean_trace, true
    set :css_files, :blob
    set :js_files, :blob
    MinifyResources.minify_all
  end

  configure :development do
    set :haml, { :ugly => true }
    set :css_files, MinifyResources::CSS_FILES
    set :js_files, MinifyResources::JS_FILES
    register Sinatra::Reloader
  end

  set :public_folder, Proc.new { File.join(root, '/public/', $config['theme']) }
  set :views, Proc.new { File.join(root, '/views/', $config['theme']) }

  helpers do
    include Rack::Utils
    alias_method :h, :escape_html
  end
end

require_relative 'helpers/init'
require_relative 'models/init'
require_relative 'routes/init'
