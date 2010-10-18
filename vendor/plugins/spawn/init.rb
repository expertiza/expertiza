require 'patches'
require 'spawnhelper'

ActiveRecord::Base.send :include, Spawn
ActionController::Base.send :include, Spawn
ActiveRecord::Observer.send :include, Spawn
Rails::Initializer.send :include, Spawn
Rails::Initializer.send :include, SpawnHelper