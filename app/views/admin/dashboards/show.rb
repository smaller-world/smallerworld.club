# typed: strict
# frozen_string_literal: true

class Views::Admin::Dashboards::Show < Views::Base
  # == View ==

  sig { override.void }
  def view_template
    Components::AppLayout(page_title: "admin") do |app_layout|
      app_layout.page_container(class: "max-w-lg flex flex-col gap-y-4") do
        div do
          h1(class: "text-2xl font-bold") { "admin dashboard" }
          blockquote(class: "italic text-muted-foreground") do
            "“so ya wanna build smaller worlds, is that right?”"
          end
        end

        div(class: "flex flex-col gap-y-1") do
          h2(class: "text-xl font-semibold") { "quick links" }
          ul(class: "list-disc ml-6 space-y-0.5") do
            li do
              link_to("reports", [ :admin, :reports ], class: "link")
            end
            li do
              link_to(
                "background jobs",
                admin_mission_control_jobs_path,
                class: "link",
              )
            end
          end
        end
      end
    end
  end
end
