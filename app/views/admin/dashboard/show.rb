# typed: strict
# frozen_string_literal: true

class Views::Admin::Dashboard::Show < Views::Base
  sig { override.void }
  def view_template
    Components::Layout() do |layout|
      layout.page_container(class: "flex flex-col gap-y-4") do
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
              link_to("webhook logs", [ :admin, :webhook_messages ], class: "link")
            end
            li do
              link_to("background jobs", [ :mission_control, :jobs ], class: "link")
            end
          end
        end
      end
    end
  end
end
