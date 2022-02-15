# frozen_string_literal: true

require 'minitest'
require 'minitest/hooks/test'

class BaseTest < MiniTest::Test
  include Minitest::Hooks

  cattr_accessor :adapter

  def around_all
    pid = start_sidekiq(adapter)
    super
    kill(pid)
  end

  def setup
    redis_test_reset
    @start_time = Time.now
    super
  end

  # The duration of the test in seconds.
  #
  # @return [Integer] the test duration
  def duration
    Time.now - @start_time
  end
end
