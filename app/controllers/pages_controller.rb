# typed: true
# frozen_string_literal: true

class PagesController < PublicController
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

  # GET /home
  def home
    respond_to do |format|
      format.html do
        render Views::Pages::Home
      end
    end
  end
end
