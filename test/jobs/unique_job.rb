# frozen_string_literal: true

class UniqueJob < BaseJob
  include ActiveJob::Locking::Unique
end
