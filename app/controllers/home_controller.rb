# typed: true
# frozen_string_literal: true

class HomeController < ApplicationController
  # == Actions ==

  # GET /home
  def show
    respond_to do |format|
      format.html do
        render Views::Pages::Home
      end
    end
  end
end
