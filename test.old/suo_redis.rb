ActiveJob::Base.queue_adapter = :test
ActiveJob::Base.queue_adapter.perform_enqueued_jobs = true
ActiveJob::Locking.options.adapter = ActiveJob::Locking::Adapters::SuoRedis
