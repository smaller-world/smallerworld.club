# typed: true
# frozen_string_literal: true

class Views::Home::Show < Views::Base
  include Phlex::Rails::Helpers::ButtonTo

  # == View ==

  sig { override.void }
  def view_template
    user = Current.user
    Components::Layout() do |layout|
      layout.page_container(class: "max-w-xl flex flex-col gap-y-4") do
        Components::Card() do |card|
          card.content(class: "flex items-center gap-x-4") do
            div(class: "flex-1 flex items-center gap-x-4") do
              if (blob = user.oauth_picture_blob)
                image_tag(blob, class: "size-16 rounded-full")
              end
              div(class: "flex flex-col gap-y-1") do
                span(class: "font-semibold text-lg") do
                  "hi, #{user.name}"
                end
                code(class: "text-xs text-muted-foreground") do
                  user.email_address
                end
              end
            end
            button_to(
              session_path,
              method: :delete,
              **Components::Button.new(variant: :destructive).root_attributes,
            ) do
              Icon(
                "huge/logout-01",
                class: "size-4",
                data: { icon: "inline-start" },
              )
              span { "sign out" }
            end
          end
        end

        Components::DropdownMenu() do |menu|
          menu.trigger do
            Components::Button(variant: :secondary) { "Options" }
          end
          menu.content do
            menu.group do
              menu.label { "Actions" }
              menu.link_item(href: "#") { "Edit" }
              menu.button_item { "Duplicate" }
            end
            menu.separator
            menu.button_item(variant: :destructive) { "Delete" }
          end
        end

        Components::Button(command: "show-modal", commandfor: "test-dialog") do
          "Open dialog"
        end

        Components::Dialog(id: "test-dialog") do |d|
          d.header do
            d.title { "Hello from Dialog" }
            d.description do
              "This is a test dialog using Tailwind Elements + shadcn styling."
            end
          end
          d.body do
            p do
              "It works! Close me with the X button, the Cancel button, or " \
                "press Escape."
            end
          end
          d.footer do
            Components::Button(
              variant: :outline,
              command: "close",
              commandfor: "test-dialog",
            ) do
              "Cancel"
            end
            Components::Button(command: "close", commandfor: "test-dialog") do
              "Confirm"
            end
          end
        end
      end
    end
  end
end
