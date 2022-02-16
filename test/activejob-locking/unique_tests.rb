# frozen_string_literal: true

module UniqueTests
  # def test_in_serial_only_first_is_performed
  #   UniqueJob.lock_acquire_time = 1
  #   serial(3) { |id| UniqueJob.perform_later(id, sleep_time: 10) }
  #
  #   assert_equal(1, enqueued_jobs.count)
  #   assert_equal(1, performed_jobs.count)
  #   assert(duration >= 2.seconds, duration)
  # end

  def test_in_parallel_only_first_is_performed
    skip(not_a_dlm) unless distributed_lock_manager?

    UniqueJob.lock_acquire_time = 1
    parallel(3) { |id| UniqueJob.perform_later(id, sleep_time: 10) }

    assert_equal(1, enqueued_jobs.count)
    assert_equal(1, performed_jobs.count)
    assert(duration >= 1.second, duration)
  end

  # def test_in_concurrent_only_first_is_performed
  #   UniqueJob.lock_acquire_time = 1
  #   concurrent(3) { |id| UniqueJob.perform_later(id, sleep_time: 10) }
  #
  #   assert_equal(1, enqueued_jobs.count)
  #   assert_equal(1, performed_jobs.count)
  #   assert(duration >= 1.second, duration)
  # end





  ### TODO





  # def test_in_serial_all_performed
  #   UniqueJob.lock_acquire_time = 3
  #
  #   serial(3) { |id| UniqueJob.perform_later(id, sleep_time: 1) }
  #
  #   assert_equal(3, enqueued_jobs.count)
  #   assert_equal(3, performed_jobs.count)
  #   assert(duration >= 3.seconds, duration)
  # end
  #
  # def test_in_parallel_all_performed
  #   UniqueJob.lock_acquire_time = 3
  #
  #   parallel(3) { |id| UniqueJob.perform_later(id, sleep_time: 1) }
  #
  #   assert_equal(3, enqueued_jobs.count)
  #   assert_equal(3, performed_jobs.count)
  #   assert(duration >= 3.seconds, duration)
  # end
  #
  # def test_in_concurrent_all_performed
  #   UniqueJob.lock_acquire_time = 3
  #
  #   concurrent(3) { |id| UniqueJob.perform_later(id, sleep_time: 1) }
  #
  #   assert_equal(3, enqueued_jobs.count)
  #   assert_equal(3, performed_jobs.count)
  #   assert(duration >= 3.seconds, duration)
  # end





  ### TODO




  # def test_in_serial_some_performed
  #   UniqueJob.lock_acquire_time = 1
  #
  #   serial(5) { |id| UniqueJob.perform_later(id, sleep_time: 4) }
  #
  #   assert_equal(3, enqueued_jobs.count)
  #   assert_equal(3, performed_jobs.count)
  #   assert(duration >= 3.seconds, duration)
  # end
  #
  # def test_in_parallel_some_performed
  #   UniqueJob.lock_acquire_time = 3
  #
  #   parallel(10) { |id| UniqueJob.perform_later(id, sleep_time: 3) }
  #
  #   assert_equal(3, enqueued_jobs.count)
  #   assert_equal(3, performed_jobs.count)
  #   assert(duration >= 3.seconds, duration)
  # end
  #
  # def test_in_concurrent_some_performed
  #   UniqueJob.lock_acquire_time = 3
  #
  #   concurrent(10) { |id| UniqueJob.perform_later(id, sleep_time: 3) }
  #
  #   assert_equal(3, enqueued_jobs.count)
  #   assert_equal(3, performed_jobs.count)
  #   assert(duration >= 3.seconds, duration)
  # end






end
