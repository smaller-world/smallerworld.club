# typed: strict
# frozen_string_literal: true

credentials = Rails.application.credentials.resend

if credentials
  Resend.api_key = credentials.api_key
end
