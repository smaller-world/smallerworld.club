# typed: strict
# frozen_string_literal: true

class Components::AcceptWorldCardKeyGrantForm < Components::Base
  # == Initialization ==

  sig { params(card: WorldCard, attributes: T.untyped).void }
  def initialize(card:, **attributes)
    super(**attributes)
    @card = card
    @world = T.let(card.world!, World)
  end

  # == Component ==

  sig { override.void }
  def view_template
    form_with(url: [ :accept, @card, :key_grant ], **@attributes) do |form|
      submit_button_for(form, size: :lg) do
        Icon("huge/door-01")
        span { "enter #{@world.name}" }
      end
    end
  end
end
