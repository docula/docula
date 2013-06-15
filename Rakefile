require 'rake/testtask'

desc 'Launch the app with shotgun.'
task :shotgun do
   system 'shotgun'
end

desc 'Launch the app with rackup.'
task :rackup do
   system 'rackup'
end

Rake::TestTask.new do |t|
  t.pattern = 'test/**/*_spec.rb'
  t.libs.push 'test'
end