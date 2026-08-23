# typed: strict
# frozen_string_literal: true

class Views::UserReports::New < Views::Base
  # == Initialization ==

  sig { params(user: User, world: World, report: Report).void }
  def initialize(user:, world:, report:)
    super()
    @user = user
    @world = world
    @report = report
  end

  # == View ==

  sig { override.void }
  def view_template
    Components::AppLayout(page_title: "report #{@user.name}") do |app_layout|
      app_layout.with_navigation(class: "max-w-md") do
        button_back_to(@world.name, @world, variant: :secondary)
      end

      app_layout.page_container(class: "max-w-md") do
        Components::ReportForm(report: @report)
      end
    end
  end
end
