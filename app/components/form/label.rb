# typed: strict
# frozen_string_literal: true

class Components::Form
  class Label < Superform::Rails::Components::Label
    # == Component ==

    sig do
      params(content: T.nilable(
        T.proc.params(field_label: Components::FieldLabel).returns(T.anything),
      )).void
    end
    def view_template(&content)
      Components::FieldLabel(**attributes) do |field_label|
        if block_given?
          yield(field_label)
        else
          plain(label_text)
        end
      end
    end

    sig { override.returns(String) }
    def label_text
      super.humanize(capitalize: false)
    end
  end
end
