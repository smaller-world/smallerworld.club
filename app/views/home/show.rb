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
              if (picture = user.oauth_picture)
                image_tag(picture, class: "size-16 rounded-full")
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
      end
    end
  end
end
