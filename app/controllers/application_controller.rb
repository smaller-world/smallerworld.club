# typed: true
# frozen_string_literal: true

class ApplicationController < ActionController::Base
  extend T::Sig
  extend T::Helpers

  include Pagy::Method
  include Authentication
  include TaggedLogging

  # == Configuration ==

  layout false

  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

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
