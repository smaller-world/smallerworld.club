# typed: true
# frozen_string_literal: true

module Admin
  class ReportsController < AdminController
    # == Actions ==

    # GET /admin/reports
    def index
      respond_to do |format|
        format.html do
          authorize!
          scope = authorized_scope(Report.all)
          reports = scope.includes(:reporter, :reportable).pending_first
          pagy, reports = pagy(:countish, reports)
          render Views::Admin::Reports::Index.new(reports:, pagy:)
        end
      end
    end

    # GET /admin/reports/:id
    def show
      respond_to do |format|
        format.html do
          current_user = Current.user!
          report = find_report
          authorize!(report)
          render Views::Admin::Reports::Show.new(current_user:, report:)
        end
      end
    end

    # POST /admin/reports/:id/resolve
    def resolve
      respond_to do |format|
        format.html do
          current_user = Current.user!
          report = find_report
          authorize!(report)
          resolution = params.require(:report).fetch(:resolution)
          report.resolve!(resolution:, moderator: current_user)
          resolution = report.resolution!
          redirect_to(
            [ :admin, report ],
            notice: "report #{resolution.text}.",
            status: :see_other,
          )
        end
      end
    end

    private

    # == Helpers ==

    sig { returns(Report) }
    def find_report
      Report.find(params.fetch(:id))
    end
  end
end
