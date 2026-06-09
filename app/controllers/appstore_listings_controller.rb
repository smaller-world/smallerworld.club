# typed: true
# frozen_string_literal: true

class AppstoreListingsController < ApplicationController
  # == Actions ==

  # GET /appstore
  def show
    redirect_to(Rails.configuration.testflight_url)
  end
end
