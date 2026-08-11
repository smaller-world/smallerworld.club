# typed: true
# frozen_string_literal: true

module Admin
  class DashboardsController < AdminController
    # == Actions ==

    # GET /admin
    def show
      respond_to do |format|
        format.html do
          authorize!(with: DashboardPolicy)
          render Views::Admin::Dashboards::Show
        end
      end
    end
  end
end
