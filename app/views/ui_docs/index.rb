# typed: strict
# frozen_string_literal: true

class Views::UiDocs::Index < Views::Base
  # == Configuration ==

  COMPONENTS = [ :alerts ].freeze

  # == View ==

  sig { override.void }
  def view_template
    Components::AppLayout(page_title: "ui") do |layout|
      layout.page_container do
        div(class: "mx-auto max-w-4xl space-y-8 py-8") do
          # Header
          div(class: "space-y-2") do
            h1(class: "text-3xl font-bold tracking-tight") { "Components" }
            p(class: "text-muted-foreground") do
              "A collection of UI components built with Phlex and Tailwind CSS."
            end
          end

          # Component grid
          div(
            class: [
              "grid grid-cols-2 gap-3 sm:grid-cols-3 md:grid-cols-4",
              "font-medium [&_a]:hover:underline",
            ],
          ) do
            COMPONENTS.each do |component|
              link_to(
                component.to_s.titleize,
                ui_doc_path(component),
              )
            end
          end
        end
      end
    end
  end
end
