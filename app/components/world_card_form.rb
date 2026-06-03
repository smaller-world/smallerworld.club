# typed: strict
# frozen_string_literal: true

class Components::WorldCardForm < Components::Base
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
    form_with(model: [ @world, @card ], **normalize_mix(
      {
        data: {
          controller: "world-card-form",
        },
      },
      @attributes,
    )) do |form|
      form.hidden_field(
        :grant,
        value: @world.key_grant(color: @card.granted_key_color),
      )
      div(class: "flex flex-col gap-3") do
        submit_button_for(
          form,
          size: :lg,
          data: {
            world_card_form_target: "submitButton",
          },
        ) do
          Icon("huge/cards-02")
          span { "add keycard to wallet" }
        end
        span(class: "text-sm text-muted-foreground text-center text-balance") do
          plain("once you've ")
          a(
            href: Rails.configuration.testflight_url,
            target: "_blank",
            rel: "noopener noreferrer",
            class: "text-primary",
          ) do
            "download the app"
          end
          plain(", this card will give you access to #{@world.name}")
        end
      end
    end
  end
end
