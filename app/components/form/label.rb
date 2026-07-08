# typed: strict
# frozen_string_literal: true

class Components::Form
  class Label < Superform::Rails::Components::Label
    # == Component ==

    sig { params(content: T.nilable(T.proc.returns(T.anything))).void }
    def view_template(&content)
      Components::FieldLabel(**attributes) do
        if block_given?
          yield
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
