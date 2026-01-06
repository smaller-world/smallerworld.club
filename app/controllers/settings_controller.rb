# typed: true
# frozen_string_literal: true

class SettingsController < ApplicationController
  # == Actions ==

  # GET /settings[?test_notification_success=1]
  def show
    respond_to do |format|
      format.html do
        @page_title = "settings"
        if params[:test_notification_success].truthy?
          flash.now[:notice] = "your notifications are working :) yippee!"
        end
      end
    end
  end
end
