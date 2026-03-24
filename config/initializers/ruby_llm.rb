# typed: true
# frozen_string_literal: true

RubyLLM.configure do |config|
  # config.openai_api_key = ENV["OPENAI_API_KEY"] || Rails.application.credentials.dig(:openai_api_key)
  # config.default_model = "gpt-4.1-nano"

  if (open_router = Rails.application.credentials.open_router)
    config.openrouter_api_key = open_router.api_key
  end
  config.default_model = "stepfun/step-3.5-flash:free"
  config.model_registry_class = "AIModel"

  # Use the new association-based acts_as API (recommended)
  config.use_new_acts_as = true
end
