# typed: true
# frozen_string_literal: true

class HomeController < ApplicationController
  # == Actions ==

  # GET /home
  def show
    respond_to do |format|
      format.html do
        current_user = current_user!
        render Views::Home::Show.new(current_user:)
      end
    end
  end
end
