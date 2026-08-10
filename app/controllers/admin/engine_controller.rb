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
  class EngineController < AdminController
    # == Configuration ==

    skip_verify_authorized
    skip_around_action :n_plus_one_detection
  end
end
