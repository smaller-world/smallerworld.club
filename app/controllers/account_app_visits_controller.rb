# typed: true
# frozen_string_literal: true

class AccountAppVisitsController < ApplicationController
  include RenderJsonError

  # == Configuration ==

  skip_verify_authorized

  # == Actions ==

  # POST /account/app_visits
  def create
    respond_to do |format|
      format.json do
        current_user = Current.user!
        begin
          current_user.record_app_visit!
          render(json: { user_id: current_user.id })
        rescue => error
          Sentry.capture_exception(error)
          render_json_error(error)
        end
      end
    end
  end
end
