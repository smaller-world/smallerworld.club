# typed: strict
# frozen_string_literal: true

# Signs a user in for a system test by hitting the test-only `TestsController`
# backdoor. The browser receives a real `Set-Cookie` from the response, so the
# subsequent navigation is authenticated through the normal Authentication
# concern — no driver-level cookie injection.
#
# For the one onboarding test that walks the real OTP UI, don't call this;
# drive the sign-in/account-creation forms directly via Capybara.
module SystemSessionTestHelper
  extend T::Sig
  extend T::Helpers

  requires_ancestor { ActionDispatch::SystemTestCase }

  sig { params(user: User).void }
  def sign_in_as(user)
    visit test_sign_in_path(user.id)
  end
end

ActiveSupport.on_load(:action_dispatch_system_test_case) do
  include SystemSessionTestHelper
end
