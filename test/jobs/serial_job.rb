# frozen_string_literal: true

class SerialJob < BaseJob
  include ActiveJob::Locking::Serialized

  self.lock_acquire_time = 1
end
