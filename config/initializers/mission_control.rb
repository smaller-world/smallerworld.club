# typed: true
# frozen_string_literal: true

return unless Rails.env.development?

Rails.application.configure do
  MissionControl::Jobs.base_controller_class = "PublicController"
end
