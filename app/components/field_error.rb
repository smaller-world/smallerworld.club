# typed: strict
# frozen_string_literal: true

class Components::FieldError < Components::Base
  # == Initialization ==

  sig do
    params(
      messages: T::Array[String],
      attributes: T.untyped,
    ).void
  end
  def initialize(messages: [], **attributes)
    super(**attributes)
    @messages = messages
  end

  # == Component ==

  sig { override.void }
  def view_template
    root_element(
      :div,
      class: "field-error",
      role: "alert",
      data: {
        slot: "field-error",
      },
    ) do
      if @messages.length > 1
        ul do
          @messages.each do |msg|
            li { msg }
          end
        end
      else
        @messages.first
      end
    end
  end
end
