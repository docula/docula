# encoding: utf-8
require 'sequel'

DB = Sequel.connect(:adapter => 'mysql',
                    :host => 'localhost',
                    :user => 'root',
                    :password => '',
                    :database => 'docula')

DB.drop_table :docsets
DB.create_table :docsets do
  primary_key :id
  String :name
  String :branch
  String :fs_path
end

docsets = DB[:docsets]

docsets.insert(:name => 'docula-sample', :branch => 'master', :fs_path => '/Users/Andre/GitHub/docula-sample')

require_relative 'docset'
