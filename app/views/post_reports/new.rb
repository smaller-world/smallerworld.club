# typed: strict
# frozen_string_literal: true

class Views::PostReports::New < Views::Base
  # == Initialization ==

  sig { params(post: Post, report: Report).void }
  def initialize(post:, report:)
    super()
    @post = post
    @report = report
    @world = T.let(@post.world!, World)
  end

  # == View ==

  sig { override.void }
  def view_template
    Components::AppLayout(page_title: "report post") do |app_layout|
      app_layout.page_container(class: "max-w-md space-y-6") do
        unless hotwire_native_app?
          button_back_to(@world.name, @world, variant: :secondary)
        end

        Components::ReportForm(report: @report)
      end
    end
  end
end
