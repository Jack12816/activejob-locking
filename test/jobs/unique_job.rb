# frozen_string_literal: true

class UniqueJob < BaseJob
  include ActiveJob::Locking::Unique

  self.lock_acquire_time = 1
end
