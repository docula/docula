# encoding: utf-8
require 'sequel'
require 'yaml'

$db_config = YAML.load_file('cfg/' + ENV['USER'] + '.yml')

DB = Sequel.connect(:adapter => ENV['docula.db.adapter'],
                    :host => ENV['docula.db.host'],
                    :user => ENV['docula.db.username'],
                    :password => ENV['docula.db.password'],
                    :database => ENV['docula.db.database'])

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
