# frozen_string_literal: true

module UniqueTests
  def test_in_serial_only_first_is_performed
    serial { |id| UniqueJob.perform_later(id) }

    assert_equal(1, enqueued_jobs.count)
    assert_equal(1, performed_jobs.count)
  end

  def test_in_parallel_only_first_is_performed
    parallel { |id| UniqueJob.perform_later(id) }

    assert_equal(1, enqueued_jobs.count)
    assert_equal(1, performed_jobs.count)
  end

  def test_in_concurrent_only_first_is_performed
    concurrent { |id| UniqueJob.perform_later(id) }

    assert_equal(1, enqueued_jobs.count)
    assert_equal(1, performed_jobs.count)
  end


  # TODO: lock_acquire_time

end
