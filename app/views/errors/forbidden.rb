# typed: strict
# frozen_string_literal: true

class Views::Errors::Forbidden < Views::Base
  # == View ==

  sig { override.void }
  def view_template
    Components::AppLayout(page_title: "you can't go there", class: "bg-muted") do
      main(class: "flex-1 flex items-center justify-center") do
        Components::Empty(class: "max-w-md bg-background") do |empty|
          empty.header do
            empty.media(variant: :icon) do
              Icon("huge/door-lock")
            end
            empty.title { "this door is locked." }
            empty.description do
              "sorry! you don't have access to this page :("
            end
          end
          empty.content do
            button_back_to("your worlds", home_path, variant: :secondary)
          end
        end
      end
    end
  end
end
