source 'http://rubygems.org'

raise "Invalid ruby version: #{RUBY_VERSION}" unless RUBY_VERSION[/^1\.9\.3/]

gem 'rails', '~>3.0.0'

## Gems in Alphabetical Order
gem 'automated_metareview'
gem 'bind-it'
gem 'capistrano'
gem 'delayed_job_active_record'
gem 'edavis10-ruby-web-search'
gem 'engtagger'
gem 'expertiza-authlogic', git: 'https://github.com/expertiza/authlogic.git', :require => 'authlogic'
gem 'fastercsv'
gem 'ffi-aspell'
gem 'gchart'
gem 'gchartrb', :require => 'google_chart'
gem 'gdata', :require => false
gem 'hoptoad_notifier'
gem 'jquery-rails'
gem 'mysql'
gem 'nokogiri'
gem 'open-uri-cached'
gem 'paper_trail'
gem 'rake'
gem 'raspell'
gem 'RedCloth'
gem 'rgl', :require => 'rgl/adjacency'
gem 'rjb'
gem 'rubyzip', :require => 'zip/zip'
gem 'rwordnet'
gem 'seer'
gem 'sprockets'
gem 'stanford-core-nlp'
gem 'superfish-rails'

gem 'will_paginate'

group :development do
  gem 'daemons'
  gem 'sqlite3-ruby', :require => 'sqlite3'
  gem 'selenium-webdriver'
end

group :test do
  gem 'coveralls', require: false
  gem 'cucumber-rails', require: false
  gem 'database_cleaner'
  gem 'gherkin'
  gem 'guard-rails'
  gem 'guard-rspec'
  gem 'launchy'
  gem "minitest"
  gem "minitest-reporters", '>= 0.5.0'
  gem "rspec-rails"
  gem 'shoulda'
  gem "test-unit"
end

group :development, :test do
  gem 'capybara'
  gem 'rspec-rails'
  gem 'simplecov', :require => false, :group => :test
end

gem 'rails', '~>3.0.0'
