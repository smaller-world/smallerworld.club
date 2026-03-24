# typed: true
# frozen_string_literal: true

module Authentication
  extend T::Sig
  extend T::Helpers

  requires_ancestor { ApplicationController }

  extend ActiveSupport::Concern

  included do
    extend T::Sig

    T.bind(self, T.class_of(ApplicationController))

    before_action :require_authentication
    helper_method :authenticated?
  end

  class_methods do
    extend T::Sig
    extend T::Helpers

    requires_ancestor { T.class_of(ApplicationController) }

    sig { params(options: T.untyped).void }
    def allow_unauthenticated_access(**options)
      skip_before_action(:require_authentication, **options)
    end
  end

  private

  sig { returns(T::Boolean) }
  def authenticated?
    !!resume_session
  end

  sig { void }
  def require_authentication
    resume_session || request_authentication
  end

  sig { returns(T.nilable(Session)) }
  def resume_session
    Current.session ||= find_session_by_cookie
  end

  sig { returns(T.nilable(Session)) }
  def find_session_by_cookie
    Session.find_by(id: cookies.signed[:session_id]) if cookies.signed[:session_id]
  end

  sig { void }
  def request_authentication
    session[:return_to_after_authenticating] = request.url
    redirect_path = if respond_to?(:main_app)
      public_send(:main_app).new_session_path
    else
      new_session_path
    end
    redirect_to(redirect_path)
  end

  sig { returns(String) }
  def after_authentication_url
    session.delete(:return_to_after_authenticating) || root_url
  end

  sig { params(user: User).returns(Session) }
  def start_new_session_for(user)
    user.sessions.create!(user_agent: request.user_agent, ip_address: request.remote_ip).tap do |session|
      Current.session = session
      cookies.signed.permanent[:session_id] = { value: session.id, httponly: true, same_site: :lax }
    end
  end

  sig { returns(T.nilable(String)) }
  def terminate_session
    Current.session.destroy
    cookies.delete(:session_id)
  end
end
