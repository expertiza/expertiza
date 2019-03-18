# https://stackoverflow.com/questions/21075781/redis-global-variable-with-ruby-on-rails
Redis.current = Redis::Namespace.new("expertiza", :redis => Redis.new(host: ENV.fetch('REDIS_HOST', 'localhost')))
