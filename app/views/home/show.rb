# typed: true
# frozen_string_literal: true

class Views::Home::Show < Views::Base
  sig { override.void }
  def view_template
    Components::Layout() do |layout|
      layout.page_container do
        "hi"
      end
    end
  end
end
