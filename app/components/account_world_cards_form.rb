# typed: strict
# frozen_string_literal: true

class Components::AccountWorldCardsForm < Components::Base
  # == Initialization ==

  sig { params(current_user: User, attributes: T.untyped).void }
  def initialize(current_user:, **attributes)
    @current_user = current_user
    super(**attributes)
  end

  # == Component ==

  sig { override.void }
  def view_template
    form_with(
      url: account_world_cards_path,
      method: :put,
      scope: :user,
      **normalize_mix(
        {
          data: {
            controller: "account-world-cards-form passes-bridge",
            action: "passes-bridge:received->account-world-cards-form#submitPasses",
          },
        },
        @attributes,
      ),
    ) do |form|
      template(data: { account_world_cards_form_target: "inputTemplate" }) do
        form.hidden_field(
          :world_card_pass_serial_numbers,
          multiple: true,
          value: nil,
          data: {
            account_world_cards_form_target: "addedInput",
          },
        )
      end

      @current_user.world_card_passes.pluck(:serial_number).each do |value|
        form.hidden_field(
          :world_card_pass_serial_numbers,
          multiple: true,
          value:,
          data: {
            account_world_cards_form_target: "existingInput",
          },
        )
      end
    end
  end
end
