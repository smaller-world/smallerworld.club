# typed: strict
# frozen_string_literal: true

class Components::EmojiInput < Components::Input
  # == Initialization ==

  sig do
    params(
      form: T.nilable(PhlexRailsFormBuilder),
      field: T.nilable(Symbol),
      required: T::Boolean,
      attributes: T.untyped,
    ).void
  end
  def initialize(
    form: nil,
    field: nil,
    required: false,
    **attributes
  )
    super(form:, field:, **attributes)
    @value = T.let(attributes[:value], T.nilable(String))
    @required = required
  end

  # == Component ==

  sig { override.void }
  def view_template
    id = SecureRandom.uuid
    Components::Dialog(id:, class: "emoji-input") do |dialog|
      dialog.with_trigger do
        div(class: "relative w-min") do
          Components::Input(
            form: @form,
            field: @field,
            readonly: true,
            required: @required,
            placeholder: " ",
            **mix(
              {
                data: {
                  controller: "emoji-input tippy",
                  emoji_input_dialog_outlet: "[id='#{id}']",
                  tippy_trigger_value: "mouseenter",
                  tippy_content_value: "click to clear",
                  tippy_disabled_value: !has_value?,
                  action: [
                    "click->emoji-input#clearOrOpenDialog",
                    "change->emoji-input#updateTooltip",
                  ],
                },
              },
              @attributes,
            ),
          )
          div(data: { slot: "emoji-input-placeholder" }) do
            Icon("huge/smile")
          end
        end
      end
      dialog.with_content(
        show_close_button: false,
        panel: { class: "p-0 w-min" },
      ) do
        div(data: {
          controller: "emoji-mart",
          emoji_mart_dialog_outlet: "[id='#{id}']",
          emoji_mart_emoji_input_outlet: "[id='#{id}'] [data-controller~=emoji-input]",
        })
      end
    end
  end

  private

  sig { returns(T::Boolean) }
  def has_value?
    !!@value ||
      ((object = @form&.object) && (field = @field) && !!object.public_send(field))
  end
end
