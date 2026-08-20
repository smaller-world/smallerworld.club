# typed: true
# frozen_string_literal: true

class StartController < ApplicationController
  # == Configuration ==

  allow_unauthenticated_access
  skip_verify_authorized

  # == Actions ==

  # GET /start
  def show
    respond_to do |format|
      format.html do
        redirect_url = if authenticated?
          home_path
        else
          new_session_path
        end
        redirect_to(redirect_url)
      end
    end
  end
end
