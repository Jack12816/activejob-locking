# frozen_string_literal: true

class SerialJob < BaseJob
  include ActiveJob::Locking::Serialized
end
