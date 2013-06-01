# encoding: utf-8
require 'sequel'
require 'yaml'

$db_config = YAML.load_file('models/db.yml')

DB = Sequel.connect(:adapter => $db_config['adapter'],
                    :host => $db_config['host'],
                    :user => $db_config['user'],
                    :password => $db_config['password'],
                    :database => $db_config['database'])

if ($db_config['recreate'])
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

  $db_config['data'].each do |record|
    docsets.insert(:name => record['name'], :branch => record['branch'], :fs_path => record['fs_path'])
  end
end

require_relative 'docset'
