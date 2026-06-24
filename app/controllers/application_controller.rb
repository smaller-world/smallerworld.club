# typed: true
# frozen_string_literal: true

class ApplicationController < ActionController::Base
  extend T::Sig
  extend T::Helpers

  include Pagy::Method
  include TaggedLogging

  include Authentication
  include DeviceTracking
  include SentryIdentification

  include DeviceDetection
  include LogStreaming
  include ToastStreaming

  # == Configuration ==

  layout false

  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

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
end
