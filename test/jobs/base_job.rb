# frozen_string_literal: true

class BaseJob < ActiveJob::Base
  include ActiveJob::Locking::Base

  before_perform do |job|
    track_perform(job.arguments.first)
  end

  # We want the job ids to be all the same for testing
  def lock_key(*args)
    "#{self.class.name}:#{args.first}"
  end

  # Pass in an identifier so we can distinguish different jobs
  def perform(id, sleep_time: 5)
    # TODO: ArgumentError (wrong number of arguments (given 2, expected 1)):
    # activejob-locking/test/jobs/base_job.rb:16:in `perform'
    # activejob-locking/vendor/bundle/ruby/3.0.0/gems/activejob-5.2.6.2/lib/active_job/execution.rb:39:in `block in perform_now'
    sleep(sleep_time)
  end
end
