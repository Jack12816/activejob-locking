# frozen_string_literal: true

require 'minitest'
require 'minitest/hooks/test'
require 'parallel'

class BaseTest < MiniTest::Test
  include Minitest::Hooks

  class_attribute :adapter, default: :memory
  attr_accessor :id

  def around_all
    pid = start_sidekiq(adapter)
    super
    kill(pid)
  end

  def setup
    redis_test_reset
    @id = SecureRandom.uuid
    workarounds
    @start_time = Time.now
    super
  end

  # Perform some workarounds for some adapters.
  def workarounds
    case adapter
    when :suo_redis
      # The SuoRedis client is also not a safe DLM
      # implementation. (https://github.com/nickelser/suo/issues/19)
      redis.set("activejoblocking:UniqueJob:#{id}", '')
      redis.set("activejoblocking:SerialJob:#{id}", '')
      redis.set("activejoblocking:FailJob:#{id}", '')
    end
  end

  def parallel(times = 3, &block)
    Parallel.each(times.times.to_a, in_processes: times) { block.call(id) }
    sleep 1
  end

  def concurrent(times = 3, &block)
    Parallel.each(times.times.to_a, in_threads: times) { block.call(id) }
    sleep 1
  end

  def serial(times = 3, &block)
    times.times.each { block.call(id) }
    sleep 1
  end

  # The duration of the test in seconds.
  #
  # @return [Integer] the test duration
  def duration
    (Time.now - @start_time).round
  end

  # Some locking adapters/gems are not designed as distributed lock managers,
  # so the lock may be over-aquired in a cluster. The memory adapter is such a
  # thing, it cannot work across multiple processes or machines, just across
  # threads of the same process.
  #
  # @return [Boolean] whenever the current adapter in use is able
  #   to act as a DLM or not
  def distributed_lock_manager?
    return false if %i[memory].include? adapter

    true
  end

  def not_a_dlm
    "#{adapter} is not a distributed lock manager, parallel testing skipped"
  end
end
