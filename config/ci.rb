# rubocop:disable Rails/Output, Lint/MissingCopEnableDirective
# typed: false # rubocop:disable Sorbet/TrueSigil
# frozen_string_literal: true

# Run using mise ci (or bin/ci).

def system!(*args)
  system(*args, exception: true)
end

postgres_pid = nil
if !system("bin/container-running", "postgres")
  puts "Starting Postgres for CI..."
  postgres_pid = Process.spawn(
    "bin/postgres",
    out: File::NULL,
    err: File::NULL,
    pgroup: true,
  )
  system!("bin/postgres-await")
  puts "* PID: #{postgres_pid}"
else
  system!("bin/postgres-await")
end

begin
  ActiveSupport::ContinuousIntegration.run do
    step("Security: Ruby", "mise run audit:ruby")
    step("Security: JavaScript", "mise run audit:js")
    step("Code checks", "mise run check --all")
    step("Tests", "mise run test:all -v")
  end
ensure
  if postgres_pid
    begin
      Process.kill("INT", -postgres_pid)
    rescue Errno::ESRCH
      # The process may have already exited after a startup failure.
    end
    Process.wait(postgres_pid)
  end
end
