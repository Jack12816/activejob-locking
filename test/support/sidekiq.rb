# frozen_string_literal: true

require_relative 'setup'
require 'active_job'
require 'sidekiq'

Sidekiq.logger = logger

Redis.exists_returns_integer = false \
  if Redis.respond_to? :exists_returns_integer

# Unfortunately, ActiveJob's +#after_enqueue+ is not to trust with versions
# <=6.2 (In Rails 6.2, `after_enqueue`/`after_perform` callbacks no longer run
# if `before_enqueue`/`before_perform` respectively halts with `throw
# :abort`.). This behaviour is safely enabled with Rails 7.0, but we have to
# deal with older Rails/ActiveJob versions (down to 5.2), so we implement a
# custom Sidekiq client middleware to perform the tracking. This works the same
# way was the ActiveJob callback, but a level deeper.
class TrackJobEnqueuing
  # Track the job enqueuing for testing.
  #
  # @param [String, Class] worker_class the string or class of
  #   the worker class being enqueued
  # @param [Hash] job the full job payload
  #   * @see https://github.com/mperham/sidekiq/wiki/Job-Format
  # @param [String] queue the name of the queue the job was pulled from
  # @param [ConnectionPool] redis_pool the redis pool
  # @return [Hash, FalseClass, nil] if false or nil is returned,
  #   the job is not to be enqueued into redis, otherwise the block's
  #   return value is returned
  # @yield the next middleware in the chain or the enqueuing of the job
  def call(worker_class, job, queue, redis_pool)
    track_enqueue(job['args'].first['arguments'].first)
    yield
  end
end

Sidekiq.configure_server do |config|
  config.redis = { url: redis_url }
end

Sidekiq.configure_client do |config|
  config.redis = { url: redis_url }
  config.client_middleware do |chain|
    chain.add TrackJobEnqueuing
  end
end

Sidekiq.default_worker_options = { retry: false, backtrace: false }

# Disable the Sidekiq banner (ASCII art) to unpollute the testing log.
if Sidekiq.server?
  class Sidekiq::CLI
    def print_banner
      nil
    end
  end
end

def configure_adapter(adapter)
  adapter = adapter.to_s

  ActiveJob::Base.queue_adapter = :sidekiq

  if adapter == 'memory'
    ActiveJob::Base.queue_adapter = :test
  end

  if adapter == 'redlock'
    ActiveJob::Locking.options.hosts = Redlock::Client::DEFAULT_REDIS_URLS
  end

  adapter = "ActiveJob::Locking::Adapters::#{adapter.camelize}".constantize
  logger.debug "Loaded activejob-locking adapter: #{adapter}"
  ActiveJob::Locking.options.adapter = adapter
end

def start_sidekiq(adapter = :memory)
  configure_adapter(adapter)
  redis_reset
  sidekiq_pid_file = Pathname.new(File.join(__dir__, 'sidekiq.pid'))
  sidekiq_pid = suppress(Errno::ENOENT) do
    sidekiq_pid_file.read.lines.first.to_i
  end
  kill(sidekiq_pid)
  sidekiq_pid = spawn <<~CMD
    ADAPTER=#{adapter} bundle exec sidekiq \
      -C '#{File.join(__dir__, 'sidekiq.yml')}' \
      -r '#{File.join(__dir__, 'sidekiq.rb')}'
  CMD
  sidekiq_pid_file.write(sidekiq_pid)
  Minitest.after_run { kill(sidekiq_pid) }
  sleep 2
  sidekiq_pid
end

def kill(pid)
  return unless pid
  suppress(Errno::ESRCH) { Process.kill('KILL', pid) }
end

if (adapter = ENV['ADAPTER']).present?
  configure_adapter(adapter)
end
