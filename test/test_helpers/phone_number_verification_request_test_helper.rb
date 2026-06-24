# typed: strict
# frozen_string_literal: true

# Drives the phone-number verification flow through the real controller stack —
# both the create endpoint (with Turnstile swapped to the always-passes test
# client) and the verify endpoint — so the session-level
# `:phone_number_verification_token` marker is set the same way the production
# flow sets it. Returns the verified PhoneNumberVerificationRequest.
#
# For tests where the verification flow is the subject under test, drive the
# endpoints directly instead of using this helper. For pending requests on a
# known user, use `PhoneNumberVerificationRequest.create_test_mock_for!(user)`
# (no `verified:` flag).
module PhoneNumberVerificationRequestTestHelper
  extend T::Sig
  extend T::Helpers

  requires_ancestor { ActionDispatch::IntegrationTest }

  # == Methods ==

  sig { params(phone_number: String).returns(PhoneNumberVerificationRequest) }
  def complete_phone_verification_for(phone_number:)
    post phone_number_verification_requests_path,
      params: {
        phone_number_verification_request: { phone_number: },
        "cf-turnstile-response": "dummy",
      },
      headers: { "User-Agent" => "test" },
      as: :turbo_stream

    request = PhoneNumberVerificationRequest.chronological.last!
    post verify_phone_number_verification_request_path(request),
      params: {
        phone_number_verification_request: {
          verification_code: request.verification_code,
        },
      },
      as: :turbo_stream
    request
  end
end

ActiveSupport.on_load(:action_dispatch_integration_test) do
  include PhoneNumberVerificationRequestTestHelper
end
