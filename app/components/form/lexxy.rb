# typed: strict
# frozen_string_literal: true

class Components::Form
  class Lexxy < Input
    # == Component ==

    sig { override(allow_incompatible: true).void }
    def view_template
      Components::LexxyEditor(**attributes)
    end
  end
end
