# typed: true
# frozen_string_literal: true

class HomeController < ApplicationController
  # == Configuration ==

  allow_unauthenticated_access
  skip_verify_authorized

  # == Filters ==

  before_action :redirect_to_appstore_if_app_required,
    only: :show,
    unless: :hotwire_native_app?

  # == Actions ==

  # GET /home[?require_app=1]
  def show
    respond_to do |format|
      format.html do
        if (current_user = Current.user)
          render Views::Home::Show.new(current_user:)
        else
          redirect_to(new_session_path)
        end
      end
    end
  end

  private

  # == Callbacks ==

  sig { void }
  def redirect_to_appstore_if_app_required
    if params[:require_app].present?
      redirect_to(appstore_path)
    end
  end
end
