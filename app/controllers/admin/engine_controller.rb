# typed: strict
# frozen_string_literal: true

module Admin
  # Base class for engines mounted inside the admin area (Mission Control).
  #
  # Access is gated by `AdminController#verify_admin!`. The engine's own
  # controllers can't call `authorize!`, and they issue queries we don't
  # control, so Action Policy verification and N+1 detection are opted out of.
  #
  # The engine declares its own layout, which takes precedence over the
  # `layout false` inherited from `ApplicationController`.
  class EngineController < ActionController::Base # rubocop:disable Rails/ApplicationController
    extend T::Sig
    include Authentication

    # == Action Policy ==

    verify_authorized
    authorize :user, through: -> { Current.user }
    authorize :device, through: -> { Current.device }

    # == Filters ==

    before_action :authorize_admins!

    private

    # == Callbacks ==

    sig { void }
    def authorize_admins!
      unless Rails.env.development? || Current.user!.admin?
        redirect_to(root_path, alert: "you don't have access to this page :(")
      end
    end
  end
end
