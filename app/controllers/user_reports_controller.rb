# typed: true
# frozen_string_literal: true

class UserReportsController < ApplicationController
  # == Actions ==

  # GET /users/:user_id/reports/new?world_id=...
  def new
    respond_to do |format|
      format.html do
        current_user = Current.user!
        user = find_user
        world = find_world
        authorize!(world, to: :show?)
        report = user.reports.build(reporter: current_user)
        render Views::UserReports::New.new(user:, world:, report:)
      end
    end
  end

  # POST /users/:user_id/reports
  def create
    respond_to do |format|
      format.html do
        current_user = Current.user!
        user = find_user
        authorize!(user, to: :report?)
        report_params = params.expect(report: [ :category, :note ])
        report = user.reports.build(reporter: current_user, **report_params)
        if report.save
          redirect_to(
            home_path,
            notice: "your report has been submitted and will be reviewed by our team.",
          )
        else
          render(
            Views::UserReports::New.new(user:, report:),
            status: :unprocessable_content,
          )
        end
      end
    end
  end

  private

  # == Helpers ==

  sig { returns(User) }
  def find_user
    User.find(params.fetch(:user_id))
  end

  sig { returns(World) }
  def find_world
    World.find(params.fetch(:world_id))
  end
end
