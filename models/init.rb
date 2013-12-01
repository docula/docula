require 'sequel'
require 'yaml'

database_config = YAML.load_file('cfg/database.yml') if File.exist? 'cfg/database.yml'

if (!database_config)
  database_config = {
      :adapter  => ENV['docula.db.adapter'],
      :host     => ENV['docula.db.host'],
      :user     => ENV['docula.db.username'],
      :password => ENV['docula.db.password'],
      :database => ENV['docula.db.database']
  }
end

# Database connection information is read from environment variables
DB = Sequel.connect(database_config)

# Load the actual model objects
require_relative 'docset'
