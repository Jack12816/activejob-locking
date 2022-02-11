# frozen_string_literal: true

require_relative '../test_helper'

class RedlockTest < BaseTest
  self.adapter = :redlock

  include UniqueTests
end
