# typed: true
# frozen_string_literal: true

class Components::EmojiInput < Components::Input
  # == Component ==

  sig { override.void }
  def view_template
    Components::Dialog(
      data: {
        controller: "emoji-input",
        action: "emoji-input:open-dialog->dialog#open",
      },
    ) do |dialog|
      dialog.with_trigger do
        div(class: "relative w-min") do
          Components::Input(
            form: @form,
            field: @field,
            readonly: true,
            placeholder: "",
            **mix(
              {
                class: "emoji-input",
                data: {
                  emoji_input_target: "input",
                  action: "click->emoji-input#clearOrOpenDialog",
                },
              },
              @attributes,
            ),
          )
          div(class: "emoji-input-placeholder") do
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
            "emoji-mart:select->emoji-input#setEmoji",
            "emoji-mart:select->dialog#close",
          ],
        })
      end
    end
  end
end
