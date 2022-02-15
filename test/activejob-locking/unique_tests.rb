# frozen_string_literal: true

module UniqueTests
  def test_in_serial_only_first_is_performed
    serial(3) { |id| UniqueJob.perform_later(id) }

    assert_equal(1, enqueued_jobs.count)
    assert_equal(1, performed_jobs.count)
    assert(duration >= UniqueJob.lock_acquire_time.seconds * 2)
  end

  def test_in_parallel_only_first_is_performed
    parallel(3) { |id| UniqueJob.perform_later(id) }

    assert_equal(1, enqueued_jobs.count)
    assert_equal(1, performed_jobs.count)
    assert(duration >= UniqueJob.lock_acquire_time.seconds)
  end

  def test_in_concurrent_only_first_is_performed
    concurrent(3) { |id| UniqueJob.perform_later(id) }

    assert_equal(1, enqueued_jobs.count)
    assert_equal(1, performed_jobs.count)
    assert(duration >= UniqueJob.lock_acquire_time.seconds)
  end

  def test_in_serial_all_performed
    UniqueJob.lock_acquire_time = 2

    serial(3) { |id| UniqueJob.perform_later(id, sleep_time: 1) }

    assert_equal(3, enqueued_jobs.count)
    assert_equal(3, performed_jobs.count)
    assert(duration >= 3.seconds)
  end

  def test_in_parallel_all_performed
    UniqueJob.lock_acquire_time = 2

    parallel(3) { |id| UniqueJob.perform_later(id, sleep_time: 1) }

    assert_equal(3, enqueued_jobs.count)
    assert_equal(3, performed_jobs.count)
    assert(duration >= 3.seconds)
  end

  def test_in_concurrent_all_performed
    UniqueJob.lock_acquire_time = 2

    concurrent(3) { |id| UniqueJob.perform_later(id, sleep_time: 1) }

    assert_equal(3, enqueued_jobs.count)
    assert_equal(3, performed_jobs.count)
    assert(duration >= 3.seconds)
  end













end
