require 'rake/testtask'
require 'rake'

desc 'Launch the app with shotgun.'
task :shotgun do
  Rake::Task[:test].invoke
  system 'shotgun'
end

desc 'Launch the app with rackup.'
task :rackup do
  Rake::Task[:test].invoke
  system 'rackup'
end

desc 'Launch the app with rackup in production mode.'
task :rackupprod do
  system 'rackup -E production'
end

Rake::TestTask.new do |t|
  t.pattern = 'test/**/*_spec.rb'
  t.libs.push 'test'
  t.libs.push 'helpers'
  t.libs.push 'models'
  t.libs.push 'routes'
  t.verbose = true
end
