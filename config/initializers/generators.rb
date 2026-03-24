# typed: true
# frozen_string_literal: true

Rails.application.config.generators do |g|
  g.orm(:active_record, primary_key_type: :uuid)

  # Skip templates and helpers
  g.template_engine(nil)
  g.helper(false)

  # Skip tests
  g.test_framework(nil)
  g.controller_specs(false)
  g.view_specs(false)
  g.helper_specs(false)
  g.model_specs(false)
end
