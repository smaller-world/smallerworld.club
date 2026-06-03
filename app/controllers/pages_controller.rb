# typed: true
# frozen_string_literal: true

class PagesController < PublicController
  # == Configuration ==

  skip_verify_authorized

  # == Actions ==

  # GET /
  def landing
    respond_to do |format|
      format.html do
        # flash.now[:notice] = "welcome to smaller world!"
        render Views::Pages::Landing
      end
    end
  end
end
