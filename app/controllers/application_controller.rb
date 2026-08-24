# typed: true
# frozen_string_literal: true

class ApplicationController < ActionController::Base
  extend T::Sig
  extend T::Helpers

  include Pagy::Method

  include Authentication
  include BooleanParams
  include ClientDetection
  include DeviceIdentification
  include SentryIdentification
  include LogStreaming
  include TaggedLogging
  include ToastStreaming

  # == Configuration ==

  layout false

  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # == Filters ==

  rescue_from ActionPolicy::Unauthorized, with: :render_forbidden

  # == Action Policy ==

  verify_authorized
  authorize :user, through: -> { Current.user }
  authorize :device, through: -> { Current.device }

  # == Prosopite ==

  unless Rails.env.production?
    around_action :n_plus_one_detection

    def n_plus_one_detection
      Prosopite.scan
      yield
    ensure
      Prosopite.finish
    end
  end

  private

  # == Callbacks ==

  sig { params(error: ActionPolicy::Unauthorized).void }
  def render_forbidden(error)
    render Views::Errors::Forbidden.new, layout: false, status: :forbidden
  end
end
