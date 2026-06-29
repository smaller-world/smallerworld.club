# typed: strict
# frozen_string_literal: true

class Components::FieldError < Components::Base
  # == Initialization ==

  sig do
    params(
      form: T.nilable(PhlexRailsFormBuilder),
      field: T.nilable(Symbol),
      messages: T.nilable(T::Array[String]),
      attributes: T.untyped,
    ).void
  end
  def initialize(form: nil, field: nil, messages: nil, **attributes)
    super(**attributes)
    @form = form
    @field = field
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
      if block_given?
        yield
      elsif (messages = self.messages.presence)
        if messages.length == 1
          messages.first
        else
          ul do
            messages.each do |msg|
              li { msg }
            end
          end
        end
      end
    end
  end

  private

  # == Helpers ==

  sig { returns(T.nilable(T::Array[String])) }
  def messages
    @messages || field_messages
  end

  sig { returns(T.nilable(T::Array[String])) }
  def field_messages
    if @form && @field
      full_error_messages_for(@form, @field)
    end
  end
end
