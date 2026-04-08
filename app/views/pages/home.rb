# typed: true
# frozen_string_literal: true

class Views::Pages::Home < Views::Base
  include Phlex::Rails::Helpers::ButtonTo

  # == View ==

  sig { override.void }
  def view_template
    user = Current.user
    Components::Layout() do |layout|
      layout.page_container(
        class: "flex flex-col gap-y-4 items-center justify-center",
      ) do
        div(class: "flex flex-col items-center gap-y-2") do
          if (picture = user.oauth_picture)
            image_tag(picture, class: "size-20 rounded-full")
          end
          div(class: "flex flex-col items-center gap-y-1") do
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
          data: {
            slot: "button",
            size: "default",
            variant: "destructive",
          },
        ) do
          "sign out"
        end
      end
    end
  end
end
