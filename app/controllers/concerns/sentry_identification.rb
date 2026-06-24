# typed: strict
# frozen_string_literal: true

module SentryIdentification
  extend T::Sig
  extend T::Helpers
  extend ActiveSupport::Concern
  include DeviceDetection

  requires_ancestor { ActionController::Base }

  included do
    extend T::Sig

    T.bind(self, T.class_of(ActionController::Base))

    # == Filters ==

    before_action :set_sentry_user
  end

  private

  # == Methods ==

  sig { void }
  def set_sentry_user
    if (session = Current.session)
      user = session.user!
      ip_address = PhoneNumberVerificationRequest
        .where(id: session.phone_number_verification_request_id)
        .pick(:ip_address)
      Sentry.set_user(
        id: user.id,
        username: user.name,
        phone_number: user.phone_number,
        ip_address:,
      )
    else
      Sentry.set_user({})
    end
  end
end
