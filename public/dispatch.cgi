<<<<<<< HEAD
=======
<<<<<<< HEAD
<<<<<<< HEAD
>>>>>>> 126e61ecf11c9abb3ccdba784bf9528251d30eb0
#!C:/InstantRails/ruby/bin/ruby

require File.dirname(__FILE__) + "/../config/environment" unless defined?(RAILS_ROOT)

# If you're using RubyGems and mod_ruby, this require should be changed to an absolute path one, like:
# "/usr/local/lib/ruby/gems/1.8/gems/rails-0.8.0/lib/dispatcher" -- otherwise performance is severely impaired
require "dispatcher"

ADDITIONAL_LOAD_PATHS.reverse.each { |dir| $:.unshift(dir) if File.directory?(dir) } if defined?(Apache::RubyRun)
<<<<<<< HEAD
=======
=======
#!C:/InstantRails/ruby/bin/ruby

require File.dirname(__FILE__) + "/../config/environment" unless defined?(RAILS_ROOT)

# If you're using RubyGems and mod_ruby, this require should be changed to an absolute path one, like:
# "/usr/local/lib/ruby/gems/1.8/gems/rails-0.8.0/lib/dispatcher" -- otherwise performance is severely impaired
require "dispatcher"

ADDITIONAL_LOAD_PATHS.reverse.each { |dir| $:.unshift(dir) if File.directory?(dir) } if defined?(Apache::RubyRun)
>>>>>>> c4cd6ee2acd0c2721114a9165e8bf6050a7dd1ee
=======
#!C:/InstantRails/ruby/bin/ruby

require File.dirname(__FILE__) + "/../config/environment" unless defined?(RAILS_ROOT)

# If you're using RubyGems and mod_ruby, this require should be changed to an absolute path one, like:
# "/usr/local/lib/ruby/gems/1.8/gems/rails-0.8.0/lib/dispatcher" -- otherwise performance is severely impaired
require "dispatcher"

ADDITIONAL_LOAD_PATHS.reverse.each { |dir| $:.unshift(dir) if File.directory?(dir) } if defined?(Apache::RubyRun)
>>>>>>> c4cd6ee2acd0c2721114a9165e8bf6050a7dd1ee
>>>>>>> 126e61ecf11c9abb3ccdba784bf9528251d30eb0
Dispatcher.dispatch