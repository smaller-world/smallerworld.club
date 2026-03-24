# typed: true
# frozen_string_literal: true

module Admin
  class DashboardController < AdminController
    # GET /admin
    def show
      respond_to do |format|
        format.html do
          render Views::Admin::Dashboard::Show
        end
      end
    end
  end
end
