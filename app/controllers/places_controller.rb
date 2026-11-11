# typed: true
# frozen_string_literal: true

class PlacesController < ApplicationController
  # == Configuration ==

  skip_verify_authorized

  # == Filters ==

  before_action :show_development_alert

  # == Actions ==

  # GET /places/dock
  def dock
    respond_to do |format|
      format.html do
        render Views::Places::Dock.new
      end
    end
  end

  private

  # == Callbacks ==

  sig { void }
  def show_development_alert
    flash.now[:alert] = "this feature is still in active development."
  end
end
