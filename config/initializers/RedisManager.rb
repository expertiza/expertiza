require 'redis'
require 'redis-namespace'

class RedisManager
  @redis_instance = nil

  def self.redis
    @redis_instance ||= create_redis_instance
  end

  private

  def self.create_redis_instance
    Redis::Namespace.new('expertiza', redis: Redis.new(host: ENV.fetch('REDIS_HOST', 'localhost')))
  end
end