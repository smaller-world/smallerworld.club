# typed: true
# frozen_string_literal: true

class AppstoreListingsController < PublicController
  # == Actions ==

  # GET /appstore
  def show
    redirect_to(Smallerworld.application.testflight_url, allow_other_host: true)
  end
end
