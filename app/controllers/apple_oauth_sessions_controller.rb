# typed: true
# frozen_string_literal: true

class AppleOauthSessionsController < ApplicationController
  # == Filters ==

  allow_unauthenticated_access
  before_action :oauth_client!
  skip_forgery_protection only: :callback
  before_action :protect_against_forgery_with_state!, only: :callback

  # == Actions ==

  # POST /sessions/apple_oauth
  def create
    client = oauth_client!

    # Store session time zone
    time_zone = params.expect(:time_zone)
    cookies[:session_time_zone] = {
      same_site: :none,
      secure: true,
      value: time_zone,
    }

    # Store secured state and nonce
    state = SecureRandom.hex(16)
    nonce = SecureRandom.hex(16)
    security_cookie_options = {
      same_site: :none,
      expires: 1.hour.from_now,
      secure: true,
    }
    cookies.encrypted[:apple_oauth_state] = {
      **security_cookie_options,
      value: state,
    }
    cookies.encrypted[:apple_oauth_nonce] = {
      **security_cookie_options,
      value: nonce,
    }

    authorization_url = client.authorization_uri(
      scope: [ :name, :email ],
      state:,
      nonce:,
      response_mode: :form_post,
    )
    redirect_to(authorization_url, allow_other_host: true)
  end

  # POST /sessions/apple_oauth/callback
  def callback
    nonce = delete_encrypted_cookie(:apple_oauth_nonce) or
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
    user_data = if (raw_json = params[:user])
      JSON.parse(raw_json)
    else
      {}
    end
    user = User.from_oauth_provider!(
      :apple,
      uid: id_token.sub,
      first_name: user_data.dig("name", "firstName"),
      last_name: user_data.dig("name", "lastName"),
      email_address: id_token.email,
      time_zone_name: session_time_zone,
    )

    start_new_session_for(user)
    redirect_to(after_authentication_url)
  rescue ActionController::InvalidAuthenticityToken
    raise
  rescue => error
    Rails.error.report(error)
    tag_logger do
      logger.error("Failed to sign in with Apple: #{error}")
    end
    redirect_to(new_session_path, alert: error.message)
  end

  private

  # == Helpers ==

  sig { void }
  def protect_against_forgery_with_state!
    expected = delete_encrypted_cookie(:apple_oauth_state) or
      raise ActionController::InvalidAuthenticityToken, "Missing state"
    received = params.expect(:state)
    return if expected.present? &&
      ActiveSupport::SecurityUtils.secure_compare(expected, received.to_s)

    raise ActionController::InvalidAuthenticityToken, "State mismatch"
  end

  sig { params(name: Symbol).returns(T.nilable(String)) }
  def delete_encrypted_cookie(name)
    value = cookies.encrypted[name]
    cookies.delete(name)
    value
  end

  sig { returns(AppleID::Client) }
  def oauth_client!
    credentials = Rails.application.credentials.appleid!
    @oauth_client ||= AppleID::Client.new(
      identifier: credentials.client_id!,
      team_id: credentials.team_id!,
      key_id: credentials.key_id!,
      private_key: OpenSSL::PKey::EC.new(credentials.private_key!),
      redirect_uri: callback_apple_oauth_session_url,
    )
  end
end
