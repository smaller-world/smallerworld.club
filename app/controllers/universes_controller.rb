# typed: true
# frozen_string_literal: true

class UniversesController < ApplicationController
  # == Actions ==

  # GET /universe
  def show
    respond_to do |format|
      format.html
    end
  end
end
