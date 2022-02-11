module ActiveJob
  module Locking
    module Unique
      extend ::ActiveSupport::Concern

      included do
        include ::ActiveJob::Locking::Base

        before_enqueue do |job|
          lock = job.adapter.lock
          throw :abort unless lock
        end

        rescue_from(Exception) do |exception|
          adapter = self.adapter
          adapter.unlock if adapter.lock_token
          raise
        end

        after_perform do |job|
          adapter = job.adapter
          adapter.unlock if adapter.lock_token
        end
      end
    end
  end
end
