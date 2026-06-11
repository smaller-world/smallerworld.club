# typed: strict
# frozen_string_literal: true

class Components::NewReactionForm < Components::Base
  # == Initialization ==

  sig { params(reaction: Reaction, attributes: T.untyped).void }
  def initialize(reaction:, **attributes)
    super(**attributes)
    @reaction = reaction
    @post = T.let(@reaction.post!, Post)
  end

  # == Component ==

  sig { override.void }
  def view_template
    form_with(model: [ @post, @reaction ], **normalize_mix(
      {
        data: {
          controller: "form emoji-input confetti haptic-bridge",
          action: [
            "emoji-input:emoji-set->form#requestSubmit",
            "turbo:submit-end->confetti#launch",
            "turbo:submit-end->haptic-bridge#vibrate",
          ],
          confetti_canvas_id_value: Rails.configuration.confetti_canvas_id,
        },
      },
      @attributes,
    )) do |form|
      form.hidden_field(:emoji, data: {
        confetti_target: "input",
        emoji_input_target: "input",
      })

      Components::Dialog() do |dialog|
        dialog.with_trigger_button(
          variant: existing_reactions? ? :ghost : :outline,
          size: :icon,
          **normalize_mix(
            {
              class: "rounded-full loading-while-submitting",
              data: {
                testid: "new_reaction_dialog_trigger",
                confetti_target: "position",
                form_target: "disableWhileSubmitting",
              },
              aria: {
                invalid: ("true" if error_messages.any?),
              },
            },
            error_tooltip_attributes,
          ),
        ) do
          Icon("huge/heart-add", class: "size-4.5")
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

  private

  # == Helpers ==

  sig { returns(T.nilable(T::Hash[Symbol, T.untyped])) }
  def error_tooltip_attributes
    if (message = error_messages.first)
      {
        data: {
          controller: "tippy",
          tippy_content_value: message,
          tippy_placement_value: "bottom",
          tippy_show_on_create_value: true,
        },
      }
    end
  end

  sig { returns(T::Array[String]) }
  def error_messages
    @reaction.errors.messages_for(:emoji)
  end

  sig { returns(T::Boolean) }
  def existing_reactions?
    reactions = @post.reactions
    if reactions.loaded?
      reactions.any?(&:persisted?)
    else
      reactions.exists?
    end
  end
end
