require 'sequel'
require 'yaml'

# Database connection information is read from environment variables
DB = Sequel.connect(:adapter  => ENV['docula.db.adapter'],
                    :host     => ENV['docula.db.host'],
                    :user     => ENV['docula.db.username'],
                    :password => ENV['docula.db.password'],
                    :database => ENV['docula.db.database'])

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
    String :fs_path
  end

  docsets = DB[:docsets]

  $config['data'].each do |record|
    docsets.insert(:name    => record['name'],
                   :branch  => record['branch'],
                   :fs_path => record['fs_path'])
  end
end

require_relative 'docset'
