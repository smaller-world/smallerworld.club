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
        render Views::Places::Dock
      end
    end
  end
end
