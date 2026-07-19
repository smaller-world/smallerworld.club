# typed: strict
# frozen_string_literal: true

class Components::Form
  class Error < Superform::Rails::Components::Base
    # == Component ==

    sig do
      override.params(
        content: T.nilable(
          T.proc.params(field_error: Components::FieldError).returns(T.anything),
        ),
      ).void
    end
    def view_template(&content)
      Components::FieldError(messages: field.errors, **attributes, &content)
    end
  end
end
