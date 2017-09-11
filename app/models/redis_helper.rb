class RedisHelper
  class << self
    def fetch_hash_data(key)
      JSON.parse($redis.get(key)).deep_symbolize_keys
    end

    def store_hash_data(key, data)
      $redis.set(key, data.to_json)
    end
  end
end
