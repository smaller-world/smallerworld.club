# typed: true
# frozen_string_literal: true

module SessionTestHelper
  extend T::Sig
  extend T::Helpers

  requires_ancestor { ActionDispatch::IntegrationTest }

  # == Methods ==

  sig { params(user: User).void }
  def sign_in_as(user)
    Current.session = user.sessions.create!(
      phone_number_verification_request: PhoneNumberVerificationRequest.new(
        phone_number: user.phone_number,
        verified_at: Time.current,
        user_agent: "test",
        ip_address: IPAddr.new("127.0.0.1"),
      ),
    )

    ActionDispatch::TestRequest.create.cookie_jar.tap do |cookie_jar|
      cookie_jar.signed[:session_id] = Current.session&.id
      cookies["session_id"] = cookie_jar[:session_id]
    end
  end

  sig { void }
  def sign_out
    Current.session&.destroy!
    cookies.delete("session_id")
  end
end

ActiveSupport.on_load(:action_dispatch_integration_test) do
  include SessionTestHelper
end
