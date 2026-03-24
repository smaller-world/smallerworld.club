# typed: true
# frozen_string_literal: true

class PagesController < PublicController
  # == Actions ==

  # GET /
  def landing
    respond_to do |format|
      format.html do
        # flash.now[:notice] = "welcome to happy town!"
        render Views::Pages::Landing
      end
    end
  end
end
