# typed: strict
# frozen_string_literal: true

class Components::FieldError < Components::Base
  # == Initialization ==

  sig do
    params(
      messages: T.nilable(T::Array[String]),
      attributes: T.untyped,
    ).void
  end
  def initialize(messages: nil, **attributes)
    super(**attributes)
    @messages = messages
  end

  # == Component ==

  sig { override.params(content: T.nilable(T.proc.void)).void }
  def view_template(&content)
    root_element(
      :div,
      class: "field-error",
      role: "alert",
      data: {
        slot: "field-error",
      },
    ) do
      if content
        yield
      elsif (messages = @messages)
        if messages.length > 1
          ul do
            messages.each do |msg|
              li { msg }
            end
          end
        else
          messages.first
        end
      end
    end
  end
end
