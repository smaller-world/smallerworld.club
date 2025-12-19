# typed: true
# frozen_string_literal: true

module EmulatesExpiredPage
  extend T::Sig
  extend T::Helpers
  extend ActiveSupport::Concern

  # == Annotations ==

  requires_ancestor { ActionController::Base }
  requires_ancestor { ActionController::RequestForgeryProtection }

  private

  sig do
    params(session: T.nilable(ActionDispatch::Request::Session))
      .returns(String)
  end
  def global_csrf_token(session = nil)
    if should_fake_csrf?
      csrf_token_hmac(nil, "!real_csrf_token")
    else
      super
    end
  end

  # == Helpers ==

  sig { returns(T::Boolean) }
  def emulating_expired_page?
    params[:emulate_expired_page].truthy?
  end

  sig { returns(T::Boolean) }
  def should_fake_csrf?
    emulating_expired_page? && !request.inertia?
  end
end
