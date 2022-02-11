# frozen_string_literal: true

require_relative 'support/setup'
require_relative 'support/sidekiq'

require 'minitest/autorun'
require 'minitest/hooks'
require 'minitest/fork_executor'
Minitest.parallel_executor = Minitest::ForkExecutor.new

# Print some information
puts
puts <<DESC
  -------------- Versions --------------
            Ruby: #{RUBY_VERSION}
      Active Job: #{ActiveJob.version}
  Active Support: #{ActiveSupport.version}
  --------------------------------------
DESC
puts
