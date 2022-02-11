# frozen_string_literal: true

require 'redis'

def redis_url
  'redis://localhost:6379/1'
end

def redis
  @redis ||= Redis.new(url: redis_url)
end

def redis_reset
  logger.debug '> Reset the full redis store'
  redis.flushall
end

def redis_test_reset
  [
    redis.keys('test:*'),
    redis.keys('activejoblocking:*')
  ].flatten.each do |key|
    logger.debug "> Reset testing key '#{key}'"
    redis.del(key)
  end
end

def track_enqueue(id)
  logger.debug "> Track '#{id}' as enqueued"
  redis.set("test:enqueued:#{id}:#{SecureRandom.uuid}", 1)
end

def track_perform(id)
  logger.debug "> Track '#{id}' as performed"
  redis.set("test:performed:#{id}:#{SecureRandom.uuid}", 1)
end

def enqueued_jobs
  redis.keys('test:enqueued:*').map { |key| key.split(':')[2] }
end

def performed_jobs
  redis.keys('test:performed:*').map { |key| key.split(':')[2] }
end
