# frozen_string_literal: true

class BaseJob < ActiveJob::Base
  include ActiveJob::Locking::Base

  before_perform do |job|
    track_perform(job.arguments.first)
  end

  # We want the job ids to be all the same for testing
  def lock_key(id, sleep_time: 5)
    "#{self.class.name}:#{id}:#{sleep_time}"
  end

  # Pass in an identifier so we can distinguish different jobs
  def perform(id, sleep_time: 5)
    sleep(sleep_time)
  end
end
