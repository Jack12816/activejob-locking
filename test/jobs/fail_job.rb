# frozen_string_literal: true

class FailJob < BaseJob
  include ActiveJob::Locking::Unique

  self.lock_acquire_time = 1

  # Pass in an identifier so we can distinguish different jobs
  def perform(id, sleep_time: 5)
    raise(ArgumentError, 'Job failed')
  end
end
