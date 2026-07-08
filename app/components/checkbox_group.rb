# typed: strict
# frozen_string_literal: true

class Components::CheckboxGroup < Components::FieldGroup
  sig { override.params(content: T.proc.void).void }
  def view_template(&content)
    Components::FieldGroup( # rubocop:disable Style/ExplicitBlockArgument
      **mix(
        {
          data: {
            slot: "checkbox-group",
          },
        },
        @attributes,
      ),
    ) do
      yield
    end
  end
end
