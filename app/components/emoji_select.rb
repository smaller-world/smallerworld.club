# typed: strict
# frozen_string_literal: true

class Components::EmojiSelect < Components::Input
  include DeleteFrom

  # == Initialization ==

  sig { override.void }
  def view_template
    attributes = @attributes
    input_attributes = delete_from(attributes, :id, :name, :value, :required)

    Components::Dialog(**mix(
      {
        class: "emoji-select",
        data: {
          controller: "emoji-select",
          action: [
            "emoji-select:request-open-picker->dialog#open",
          ],
        },
      },
      attributes,
    )) do |dialog|
      dialog.with_trigger do
        div(class: "relative w-min") do
          Components::Input(
            readonly: true,
            placeholder: " ",
            **mix(
              {
                data: {
                  slot: "emoji-select-input",
                  emoji_select_target: "input",
                  controller: "tooltip",
                  tooltip_trigger_value: "mouseenter",
                  tooltip_content_value: "click to clear",
                  tooltip_disabled_value: input_attributes[:value].blank?,
                  action: [
                    "click->emoji-select#clearOrRequestOpenPicker",
                    "change->emoji-select#requestInputTooltipUpdate",
                    "emoji-select:request-disable-tooltip->tooltip#disable",
                    "emoji-select:request-enable-tooltip->tooltip#enable",
                  ],
                },
                aria: {
                  invalid: ("true" if @invalid),
                },
              },
              input_attributes,
            ),
          )
          div(data: { slot: "emoji-select-placeholder" }) do
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
          action: [
            "emoji-mart:select->emoji-select#receiveSelection",
            "emoji-mart:select->dialog#close",
          ],
        })
      end
    end
  end
end
