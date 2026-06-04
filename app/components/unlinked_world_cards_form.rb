# typed: strict
# frozen_string_literal: true

class Components::UnlinkedWorldCardsForm < Components::Base
  # == Component ==

  sig { override.void }
  def view_template
    form_with(
      url: unlinked_world_cards_path,
      method: :get,
      hidden: true,
      **normalize_mix(
        {
          data: {
            controller: "unlinked-world-cards-form passes-bridge",
            action: "passes-bridge:received->unlinked-world-cards-form#submitPasses",
          },
        },
        @attributes,
      ),
    ) do |form|
      template(data: { unlinked_world_cards_form_target: "inputTemplate" }) do
        form.hidden_field(
          :pass_serial_numbers,
          multiple: true,
          value: nil,
          data: {
            unlinked_world_cards_form_target: "input",
          },
        )
      end
    end
  end
end
