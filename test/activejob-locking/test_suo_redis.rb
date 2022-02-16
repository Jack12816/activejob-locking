# frozen_string_literal: true

require_relative '../test_helper'

class SuoRedisTest < BaseTest
  self.adapter = :suo_redis

  include UniqueTests
end
