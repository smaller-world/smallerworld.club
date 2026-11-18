# typed: strict
# frozen_string_literal: true

class Components::ReflectionForm < Components::Base
  include Phlex::Rails::Helpers::L

  # == Initialization ==

  sig { params(reflection: Reflection, attributes: T.untyped).void }
  def initialize(reflection:, **attributes)
    super(**attributes)
    @reflection = reflection
  end

  # == Component ==

  sig { override.void }
  def view_template
    Components::Form(
      @reflection,
      id: "reflection_form",
      action: reflection_path(@reflection.date.iso8601),
      method: :put,
      **mix(
        {
          class: "reflection-form",
          data: {
            controller: "haptic-bridge",
            action: "turbo:submit-end->haptic-bridge#vibrate",
          },
        },
        @attributes,
      ),
    ) do |form|
      div(class: "flex flex-col gap-4") do
        Components::FieldGroup(class: "flex-row gap-3") do
          form.wrapped(
            form.field(:emoji).emoji,
            label: false,
            error: false,
            **mix({ class: "flex-0" }, form.error_tooltip_attributes_for(:emoji)),
          )
          form.wrapped(
            form.field(:date).text(
              name: nil,
              value: localized_date,
              placeholder: "a title!",
              readonly: true,
            ),
            label: false,
            error: false,
            class: "flex-1",
          )
        end

        Components::Field(invalid: form.invalid?(:body)) do |field|
          form.Field(:body).lexxy(
            placeholder: "what happened today?",
            required: true,
            class: "min-h-36",
            data: {
              action: "keydown.meta+enter->submit#request",
            },
          )
          form.error_for(:body, class: "text-center")
          field.description(
            class: "text-center text-xs transition-opacity",
          ) do
            "write freely! your entries are encrypted."
          end
        end
      end

      form.submit(size: :lg) do |button|
        button.inline_start_icon("huge/floppy-disk")
        span do
          if @reflection.new_record?
            "save reflection"
          else
            "save changes"
          end
        end
      end
    end
  end

  private

  # == Helpers ==

  sig { returns(String) }
  def localized_date
    l(@reflection.date, format: :long).downcase
  end
end
