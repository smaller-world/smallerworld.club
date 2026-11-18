# typed: true
# frozen_string_literal: true

class PlacesController < ApplicationController
  # == Configuration ==

  skip_verify_authorized

  # == Actions ==

  # GET /places/dock
  def dock
    respond_to do |format|
      format.html do
        current_user = Current.user!
        render Views::Places::Dock.new(current_user:)
      end
    end
  end
end
