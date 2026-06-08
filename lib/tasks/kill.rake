# typed: false
# frozen_string_literal: true

desc "Kill server process by sending SIGTERM"
task :kill do # rubocop:disable Rails/RakeEnvironment
  pidfile = Rails.root.join("tmp/pids/server.pid")
  if File.file?(pidfile)
    pid = File.read(pidfile)
    system("kill", "-9", pid)
    File.delete(pidfile)
  end
end
