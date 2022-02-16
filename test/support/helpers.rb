# frozen_string_literal: true

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
