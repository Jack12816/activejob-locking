# frozen_string_literal: true

$VERBOSE = nil
$stdout.sync = true

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

  [
    Dir[File.join(__dir__, '../activejob-locking/*_test*.rb')],
    Dir[File.join(__dir__, '../jobs/**/*.rb')]
  ].flatten.sort.each { |path| require path }
end

def test_logger
  return @test_logger if @test_logger

  dev = ENV.fetch('DEBUG', 'false') == 'true' ? $stdout : IO::NULL
  formatter = Class.new(Logger::Formatter) do
    def call(*)
      "#{super.gsub(' -- :', " -- :\e[33m")}\e[0m"
    end
  end
  @test_logger = Logger.new(dev, formatter: formatter.new)
end

def third_party_logger
  dev = ENV.fetch('DEBUG', 'false') == 'true' ? $stdout : IO::NULL
  Logger.new(dev)
end

ActiveJob::Base.logger = third_party_logger
