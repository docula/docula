# This file provides common requires for all Docula tests

# common minitest libs
require 'minitest/spec'
require 'minitest/autorun'
require 'minitest/unit'
require 'minitest/pride'
require 'minitest/mock'

# commonly loaded for all the sinatra shiz
require 'haml'
require 'redcarpet'
require 'grit'
require 'yaml'
require 'sequel'
require 'sequel/adapters/mock'
require 'mocha/setup'

# our own docula things that all tests will likely need
Sequel::Model.db = Sequel.mock # dummy mock database so Sequel won't complain
require 'docset'