# typed: strict
# frozen_string_literal: true

class Components::Form
  class Error < Superform::Rails::Components::Base
    # == Component ==

    sig { override.params(content: T.nilable(T.proc.void)).void }
    def view_template(&content)
      Components::FieldError(messages: field.errors, **attributes)
    end
  end
end
