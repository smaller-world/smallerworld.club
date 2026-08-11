# typed: strict
# frozen_string_literal: true

module Authentication
  extend T::Sig
  extend T::Helpers

  requires_ancestor { ActionController::Base }

  extend ActiveSupport::Concern

  included do
    extend T::Sig

    T.bind(self, T.class_of(ActionController::Base))

    # == Configuration ==

    helper_method :authenticated?

    # == Filters ==

    before_action :resume_session
    before_action :require_authentication
  end

  class_methods do
    extend T::Sig
    extend T::Helpers

    requires_ancestor { T.class_of(ActionController::Base) }

    # == Macros ==

    sig { params(options: T.untyped).void }
    def allow_unauthenticated_access(**options)
      skip_before_action(:require_authentication, **options)
    end
  end

  private

  # == Methods ==

  sig { returns(T::Boolean) }
  def authenticated?
    !!resume_session
  end

  sig { returns(T.nilable(Session)) }
  def find_session_by_cookie
    if (session_id = cookies.signed[:session_id])
      Session.find_by(id: session_id)
    end
  end

  sig { void }
  def request_authentication
    if request.get?
      session[:return_to_after_authenticating] = request.url
    elsif (referer = request.referer)
      session[:return_to_after_authenticating] = referer
    end
    redirect_to(
      Rails.application.routes.url_helpers.new_session_path,
      notice: "please sign in to continue",
    )
  end

  sig { returns(String) }
  def after_authentication_url
    session.delete(:return_to_after_authenticating) ||
      Rails.application.routes.url_helpers.home_path
  end

  sig do
    params(
      user: User,
      phone_number_verification_request: PhoneNumberVerificationRequest,
    ).returns(Session)
  end
  def start_new_session_for(user, phone_number_verification_request:)
    user.sessions.create!(phone_number_verification_request:).tap do |session|
      Current.session = session
      cookies.signed.permanent[:session_id] = {
        value: session.id,
        httponly: true,
        same_site: :lax,
      }
    end
  end

  sig { void }
  def terminate_session
    Current.session&.destroy
    cookies.delete(:session_id)
  end

  # == Callbacks ==

  sig { returns(T.nilable(Session)) }
  def resume_session
    Current.session ||= find_session_by_cookie
  end

  sig { void }
  def require_authentication
    request_authentication unless Current.session
  end
end
