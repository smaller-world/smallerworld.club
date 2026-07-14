# typed: true
# frozen_string_literal: true

class PagesController < PublicController
  # == Actions ==

  # GET /
  def landing
    respond_to do |format|
      format.html do
        render Views::Pages::Landing
      end
    end
  end

  # GET /policies
  def policies
    respond_to do |format|
      format.html do
        render Views::Pages::Policies
      end
    end
  end
end
