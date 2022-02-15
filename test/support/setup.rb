# frozen_string_literal: true

require 'bundler'
Bundler.require(:default, :test)
require 'active_support/core_ext/string'

require_relative 'helpers'
require_relative 'redis'

# Some external gems print some deprecation warninigs, ignore them
suppress_output do
  $LOAD_PATH.unshift(File.expand_path('../../../lib', __FILE__))
  require 'activejob-locking'

  require 'activejob/locking/adapters/memory'
  require 'activejob/locking/adapters/redis-semaphore'
  require 'activejob/locking/adapters/redlock'
  require 'activejob/locking/adapters/suo-redis'
end

[
  Dir[File.join(__dir__, '../activejob-locking/*_test*.rb')],
  Dir[File.join(__dir__, '../jobs/**/*.rb')]
].flatten.sort.each { |path| require path }

def logger
  @logger ||= Logger.new(IO::NULL)
end

if ENV.fetch('DEBUG', 'false') == 'true'
  @logger = Logger.new($stdout)
end

$VERBOSE = nil
ActiveJob::Base.logger = logger
