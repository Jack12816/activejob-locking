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
    super
  end
end
