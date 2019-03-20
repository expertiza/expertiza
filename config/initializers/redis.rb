# http://ericlondon.com/2016/10/29/dockerize-rails-development-environment-integrated-with-postgresql-redis-and-elasticsearch-using-docker-compose.html
Redis.current = Redis::Namespace.new("expertiza", :redis => Redis.new(host: ENV.fetch('REDIS_HOST', 'localhost')))
