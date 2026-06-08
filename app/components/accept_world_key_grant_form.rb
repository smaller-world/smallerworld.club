# typed: strict
# frozen_string_literal: true

class Components::AcceptWorldKeyGrantForm < Components::Base
  # == Initialization ==

  sig { params(key: WorldKey, card: T.nilable(WorldCard), attributes: T.untyped).void }
  def initialize(key:, card:, **attributes)
    super(**attributes)
    @key = key
    @world = T.let(key.world!, World)
    @card = card
  end

  # == Component ==

  sig { override.void }
  def view_template
    form_with(
      url: accept_world_key_grant_path(grant: @world.key_grant(color: @key.color)),
      **@attributes,
    ) do |form|
      if (card = @card)
        form.hidden_field(:card_id, value: card.id)
      end

      submit_button_for(form, size: :lg) do
        Icon("huge/door-01")
        span { "enter #{@world.name}" }
      end
    end
  end
end
