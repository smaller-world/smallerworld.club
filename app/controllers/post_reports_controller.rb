# typed: true
# frozen_string_literal: true

class PostReportsController < ApplicationController
  # == Actions ==

  # GET /posts/:post_id/reports/new
  def new
    respond_to do |format|
      format.html do
        current_user = Current.user!
        post = find_post
        authorize!(post, to: :show?)
        report = post.reports.build(reporter: current_user)
        render Views::PostReports::New.new(post:, report:)
      end
    end
  end

  # POST /posts/:post_id/reports
  def create
    respond_to do |format|
      format.html do
        current_user = Current.user!
        post = find_post
        world = post.world!
        authorize!(post, to: :report?)
        report_params = params.expect(report: [ :category, :note ])
        report = post.reports.build(reporter: current_user, **report_params)
        if report.save
          redirect_to(
            world,
            notice: "your report has been submitted and will be reviewed by our team.",
            status: :see_other,
          )
        else
          render(
            Views::PostReports::New.new(post:, report:),
            status: :unprocessable_content,
          )
        end
      end
    end
  end

  private

  # == Helpers ==

  sig { returns(Post) }
  def find_post
    Post.find(params.fetch(:post_id))
  end
end
