require 'rake'
require 'rake/testtask'
require 'rake/rdoctask'

desc 'Default: run unit tests.'
task :default => :test

desc 'Test the redbox plugin.'
Rake::TestTask.new(:test) do |t|
  t.libs << 'lib'
  t.pattern = 'test/**/*_test.rb'
  t.verbose = true
end

desc 'Generate documentation for the redbox plugin.'
Rake::RDocTask.new(:rdoc) do |rdoc|
  rdoc.rdoc_dir = 'rdoc'
  rdoc.title    = 'Redbox'
  rdoc.options << '--line-numbers' << '--inline-source'
  rdoc.rdoc_files.include('README')
  rdoc.rdoc_files.include('lib/**/*.rb')
end

desc "Update redbox javascript and css files" 
task :update_scripts => [] do |t| 
  redbox_dir = File.expand_path(".")
  root_dir = File.join(redbox_dir, '..', '..', '..')
  File.copy File.join(redbox_dir, 'javascripts', 'redbox.js'), File.join(root_dir, 'public', 'javascripts', 'redbox.js')
  File.copy File.join(redbox_dir, 'stylesheets', 'redbox.css'), File.join(root_dir, 'public', 'stylesheets', 'redbox.css')
  File.copy File.join(redbox_dir, 'images', 'redbox_spinner.gif'), File.join(root_dir, 'public', 'images', 'redbox_spinner.gif')

  puts "Updated Scripts." 
end


