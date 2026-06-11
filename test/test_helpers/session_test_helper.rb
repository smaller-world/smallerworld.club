# typed: strict
# frozen_string_literal: true

module SessionTestHelper
  extend T::Sig
  extend T::Helpers

  requires_ancestor { ActionDispatch::IntegrationTest }

  # == Methods ==

  sig { params(user: User, device: T.nilable(Device)).void }
  def sign_in_as(user, device: nil)
    verification_request = PhoneNumberVerificationRequest
      .create_test_mock_for!(user, verified: true)
    session = user.sessions.create!(
      phone_number_verification_request: verification_request,
    )
    Current.session = session

    cookie_jar = ActionDispatch::TestRequest.create.cookie_jar
    cookie_jar.signed[:session_id] = session.id
    cookies[:session_id] = cookie_jar[:session_id]
    if device
      cookies[:device_identifier] = device.identifier
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
