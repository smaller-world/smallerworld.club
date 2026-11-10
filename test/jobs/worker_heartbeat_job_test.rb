# typed: true
# frozen_string_literal: true

require "test_helper"

class WorkerHeartbeatJobTest < ActiveJob::TestCase
  test "reports a successful heartbeat with the production schedule" do
    calls = []
    capture = lambda do |slug, status, monitor_config:|
      calls << [ slug, status, monitor_config.to_h ]
    end

    Sentry.stub(:capture_check_in, capture) do
      WorkerHeartbeatJob.perform_now
    end

    assert_equal [
      [ "worker-heartbeat", :ok, {
        schedule: { type: :crontab, value: "*/5 * * * *" },
        checkin_margin: 5,
        max_runtime: 1,
        timezone: "UTC",
      } ],
    ], calls
    recurring = YAML.load_file(Rails.root.join("config/recurring.yml"), aliases: true)
    assert_equal "WorkerHeartbeatJob", recurring.dig("production", "worker_heartbeat", "class")
    assert_equal "*/5 * * * *", recurring.dig("production", "worker_heartbeat", "schedule")
    assert_nil recurring.dig("development", "worker_heartbeat")
  end
end
