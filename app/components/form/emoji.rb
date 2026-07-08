# typed: strict
# frozen_string_literal: true

class Components::Form
  class Emoji < Input
    # == Initialization ==

    sig { override.params(field: Field, attributes: T.untyped).void }
    def initialize(field, **attributes)
      super(field, **attributes)
    end

    # == Component ==

    sig { override(allow_incompatible: true).void }
    def view_template
      Components::EmojiSelect(**attributes)
    end
  end
end
