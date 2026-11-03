# typed: true
# frozen_string_literal: true

class HomeController < ApplicationController
  # == Configuration ==

  skip_verify_authorized

  # == Actions ==

  # GET /home[?user_reported=1]
  def show
    respond_to do |format|
      format.html do
        current_user = Current.user!
        if cast_boolean(params[:report_notice])
          flash.now[:notice] = "your report has been submitted and will be reviewed by our team."
        end
        render Views::Home::Show.new(current_user:)
      end
    end
  end
end
