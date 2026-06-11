# typed: true
# frozen_string_literal: true

require "test_helper"
require "capybara/playwright"

Capybara.register_driver(:playwright) do |app|
  Capybara::Playwright::Driver.new(
    app,
    browser_type: :chromium,
    headless: true,
  )
end

Capybara.configure do |config|
  config.test_id = "data-testid"
end

class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  driven_by :playwright
end
