# typed: strict
# frozen_string_literal: true

class WorkerHeartbeatJob < ApplicationJob
  # == Job ==

  sig { void }
  def perform
    Sentry.capture_check_in("worker-heartbeat", :ok, monitor_config:,)
  end

  private

  # == Helpers ==

  sig { returns(Sentry::Cron::MonitorConfig) }
  def monitor_config
    Sentry::Cron::MonitorConfig.from_crontab(
      "*/5 * * * *",
      checkin_margin: 5,
      max_runtime: 1,
      timezone: "UTC",
    )
  end
end
