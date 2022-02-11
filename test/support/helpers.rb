# frozen_string_literal: true

require 'parallel'

def parallel(times = 3, &block)
  with_uuid do |id|
    Parallel.each(times.times.to_a, in_processes: times) { block.call(id) }
    sleep 1
  end
end

def concurrent(times = 3, &block)
  with_uuid do |id|
    Parallel.each(times.times.to_a, in_threads: times) { block.call(id) }
    sleep 1
  end
end

def serial(times = 3, &block)
  with_uuid do |id|
    times.times.each { block.call(id) }
  end
end

def with_uuid(&block)
  SecureRandom.uuid.tap do |id|
    block.call(id)
  end
end
