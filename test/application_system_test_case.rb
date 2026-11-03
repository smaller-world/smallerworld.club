# typed: strict
# frozen_string_literal: true

require "capybara/playwright"
require "test_helper"

Capybara.register_driver(:playwright)

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
