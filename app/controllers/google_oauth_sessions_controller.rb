# typed: true
# frozen_string_literal: true

class GoogleOauthSessionsController < ApplicationController
  # == Filters ==

  allow_unauthenticated_access
  before_action :oauth_client!

  # == Actions ==

  # POST /session/google_oauth
  def create
    client = oauth_client!

    time_zone = params.expect(:time_zone)
    cookies[:session_time_zone] = {
      same_site: :none,
      secure: true,
      value: time_zone,
    }

    state = SecureRandom.hex(16)
    nonce = SecureRandom.hex(16)
    security_cookie_options = {
      same_site: :none,
      expires: 1.hour.from_now,
      secure: true,
    }
    cookies.encrypted[:google_oauth_state] = {
      **security_cookie_options,
      value: state,
    }
    cookies.encrypted[:google_oauth_nonce] = {
      **security_cookie_options,
      value: nonce,
    }

    authorization_url = client.authorization_uri(
      scope: [ :openid, :email, :profile ],
      state:,
      nonce:,
    )
    redirect_to(authorization_url, allow_other_host: true)
  end

  # GET /session/google_oauth/callback
  def callback
    expected_state = delete_encrypted_cookie(:google_oauth_state) or
      raise ActionController::InvalidAuthenticityToken, "Missing state"
    received_state = params.expect(:state)
    unless ActiveSupport::SecurityUtils.secure_compare(expected_state, received_state.to_s)
      raise ActionController::InvalidAuthenticityToken, "State mismatch"
    end

    nonce = delete_encrypted_cookie(:google_oauth_nonce) or
      raise ActionController::InvalidAuthenticityToken, "Missing nonce"
    client = oauth_client!

    code = params.expect(:code)
    client.authorization_code = code
    token_response = client.access_token!
    id_token = token_response.id_token
    unless ActiveSupport::SecurityUtils.secure_compare(nonce, id_token.nonce)
      raise ActionController::InvalidAuthenticityToken, "Invalid nonce"
    end

    session_time_zone = cookies.delete(:session_time_zone) or
      raise "Missing session time zone"

    raw_claims = id_token.raw_attributes

    email = raw_claims["email"] || id_token.email
    given_name = raw_claims["given_name"]
    family_name = raw_claims["family_name"]
    picture_url = raw_claims["picture"]

    if (existing = User.find_by(email_address: email)) && existing.oauth_provider != "google"
      raise "An account with this email already exists. Please sign in with #{existing.oauth_provider.capitalize}."
    end

    user = User.from_oauth_provider!(
      :google,
      uid: id_token.sub,
      first_name: given_name,
      last_name: family_name,
      picture_url:,
      email_address: email,
      time_zone_name: session_time_zone,
    )

    start_new_session_for(user)
    redirect_to(after_authentication_url)
  rescue ActionController::InvalidAuthenticityToken
    raise
  rescue => error
    Rails.error.report(error)
    tag_logger do
      logger.error("Failed to sign in with Google: #{error}")
    end
    redirect_to(new_session_path, alert: error.message)
  end

  private

  # == Helpers ==

  sig { params(name: Symbol).returns(T.nilable(String)) }
  def delete_encrypted_cookie(name)
    value = cookies.encrypted[name]
    cookies.delete(name)
    value
  end

  sig { returns(GoogleSignIn::Client) }
  def oauth_client!
    credentials = Rails.application.credentials.google_sign_in!
    @oauth_client ||= GoogleSignIn::Client.new(
      identifier: credentials.client_id!,
      secret: credentials.client_secret!,
      redirect_uri: callback_google_oauth_session_url,
    )
  rescue => error
    raise "Failed to initialize Google OAuth client: #{error}"
  end
end
