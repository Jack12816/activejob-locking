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
    sleep 1
  end
end

def with_uuid(&block)
  SecureRandom.uuid.tap do |id|
    block.call(id)
  end
end

def suppress_output
  original_stderr = $stderr.clone
  original_stdout = $stdout.clone
  $stderr.reopen(File.new(IO::NULL, 'w'))
  $stdout.reopen(File.new(IO::NULL, 'w'))
  yield
ensure
  $stdout.reopen(original_stdout)
  $stderr.reopen(original_stderr)
end
