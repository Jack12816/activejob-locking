# frozen_string_literal: true

require_relative '../test_helper'

class RedisSemaphoreTest < BaseTest
  self.adapter = :redis_semaphore

  include UniqueTests
end
