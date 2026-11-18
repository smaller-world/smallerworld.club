# typed: strict
# frozen_string_literal: true

class Components::AppHeader
  class MenuItem
    extend T::Sig

    sig { params(content: T.proc.params(content: Components::DropdownMenu::Content).void).void }
    def initialize(&content)
      @content = content
    end

    sig { params(content: Components::DropdownMenu::Content).void }
    def render_in(content)
      @content.call(content)
    end
  end
end
