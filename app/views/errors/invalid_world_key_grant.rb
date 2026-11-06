# typed: strict
# frozen_string_literal: true

class Views::Errors::InvalidWorldKeyGrant < Views::Base
  # == View ==

  sig { override.void }
  def view_template
    Components::AppLayout(page_title: "invalid key link", class: "bg-muted") do
      main(class: "flex-1 flex items-center justify-center") do
        Components::Empty(class: "flex-0 max-w-md bg-background") do |empty|
          empty.header do
            empty.media(variant: :icon) do
              Icon("huge/door-lock")
            end
            empty.title { "this key link is invalid" }
            empty.description do
              "please ask your friend for a new link!"
            end
          end
          if authenticated?
            empty.content do
              button_back_to("your worlds", home_path, variant: :secondary)
            end
          end
        end
      end
    end
  end
end
