# typed: true
# frozen_string_literal: true

class AppstoreListingsController < PublicController
  # == Actions ==

  # GET /appstore
  def show
    redirect_to(Rails.configuration.testflight_url, allow_other_host: true)
  end
end
