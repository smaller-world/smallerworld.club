# typed: true
# frozen_string_literal: true

require "test_helper"
require "capybara/playwright"

Capybara.configure do |config|
  config.test_id = "data-testid"
  config.save_path = Rails.root.join("tmp/capybara")
end

class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  driven_by :playwright, options: {
    browser_type: :chromium,
    headless: true,
    playwright_cli_executable_path: "bunx --bun playwright",
  }
end
