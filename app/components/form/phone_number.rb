# typed: strict
# frozen_string_literal: true

class Components::Form
  class PhoneNumber < Input
    # == Component ==

    sig { override(allow_incompatible: true).void }
    def view_template
      Components::PhoneNumberInput(**attributes)
    end
  end
end
