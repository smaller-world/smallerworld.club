# typed: true
# frozen_string_literal: true

class PagesController < ApplicationController
  # == Actions ==

  # GET /
  def landing
    respond_to do |format|
      format.html
    end
  end
end
