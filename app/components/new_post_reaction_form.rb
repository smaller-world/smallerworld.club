# typed: strict
# frozen_string_literal: true

class Components::NewPostReactionForm < Components::Base
  include Phlex::Rails::Helpers::FormWith
  include NormalizeAttributes

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
    Components::Form(
      @reaction,
      action: [ @post, @reaction ],
      **mix(
        {
          data: {
            controller: "emoji-select submit confetti haptic-bridge",
            action: [
              "turbo:submit-end->confetti#launch",
              "turbo:submit-end->haptic-bridge#vibrate",
            ],
            confetti_canvas_id_value: Rails.configuration.confetti_canvas_id,
          },
        },
        @attributes,
      ),
    ) do |form|
      form.Field(:emoji).hidden(data: {
        emoji_select_target: "input",
        confetti_target: "input",
        action: "change->submit#request",
      })

      Components::Dialog(data: {
        action: "dialog:opened->emoji-select#requestPickerFocusSearch",
      }) do |dialog|
        dialog.with_trigger_button(
          variant: existing_reactions? ? :ghost : :outline,
          size: :icon,
          invalid: form.invalid?(:emoji),
          **mix(
            {
              class: "rounded-full loading-while-submitting",
              data: {
                testid: "new_post_reaction_dialog_trigger",
                confetti_target: "position",
                controller: "disable-while-submitting",
              },
            },
            form.error_tooltip_attributes_for(:emoji),
          ),
        ) do
          Icon("huge/heart-add", class: "size-4.5")
        end
        dialog.with_content(show_close_button: false, class: "p-0 w-min") do
          div(data: {
            emoji_select_target: "picker",
            controller: "emoji-mart",
            action: [
              "emoji-select:request-picker-focus-search->emoji-mart#focusSearch",
              "emoji-mart:select->emoji-select#receiveSelection",
              "emoji-mart:select->dialog#close",
            ],
          })
        end
      end
    end
  end

  private

  # == Helpers ==

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
