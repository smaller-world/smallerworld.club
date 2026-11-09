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
        saved = report.transaction do
          next false unless report.save

          WorldKey
            .where(world: user.owned_worlds, recipient: current_user)
            .or(WorldKey.where(world: current_user.owned_worlds, recipient: user))
            .find_each(&:destroy!)
          true
        end
        if saved
          if hotwire_native_ios?
            redirect_to(
              home_path(report_notice: true),
              status: :see_other,
            )
          else
            redirect_to(
              home_path,
              notice: "your report has been submitted and will be reviewed by our team.",
              status: :see_other,
            )
          end
        else
          world = user.owned_worlds
            .where(id: current_user.world_keys.select(:world_id)).first!
          render(
            Views::UserReports::New.new(user:, world:, report:),
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
