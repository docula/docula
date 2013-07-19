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

# If the recreate flag is set to true in a user's property file, we will
# recreate and seed the database with the values from the user's property file
if ($config['recreate'])
  if (DB.table_exists?(:docsets))
    DB.drop_table :docsets
  end

  DB.create_table :docsets do
    primary_key :id
    String :name
    String :branch
    Boolean :is_current
    String :fs_path
  end

  docsets = DB[:docsets]

  $config['data'].each do |record|
    docsets.insert(:name       => record['name'],
                   :branch     => record['branch'],
                   :is_current => record['is_current'],
                   :fs_path    => record['fs_path'])
  end
end

require_relative 'docset'
