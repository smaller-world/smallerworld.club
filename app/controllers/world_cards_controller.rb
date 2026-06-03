# typed: true
# frozen_string_literal: true

class WorldCardsController < ApplicationController
  # == Configuration ==

  allow_unauthenticated_access only: [ :show, :create ]
  skip_verify_authorized only: [ :show, :create ]

  # == Actions ==

  # GET /world_cards/:id
  def show
    card = find_card
    pass_path = Passkit::Factory.create_pass(Passes::WorldCard, card)
    send_file(
      pass_path,
      type: "application/vnd.apple.pkpass",
      disposition: "attachment",
    )
  end

  # POST /worlds/:world_id/cards
  def create
    respond_to do |format|
      format.html do
        world = find_world
        grant = params.require(:world_card).fetch(:grant)
        WorldKey.verify_grant(grant) => { color: }
        card = world.cards.build(
          granted_key_color: color,
          cardholder: current_user,
        )
        if card.save
          redirect_to(card, status: :see_other)
        else
          flash.now.alert = card.errors.full_messages.first
          render(
            Views::WorldKeyGrants::Show.new(key_or_card: card),
            status: :unprocessable_content,
          )
        end
      end
    end
  end

  # == Helpers ==

  sig { returns(World) }
  def find_world
    World.friendly.find(params.fetch(:world_id))
  end

  sig { returns(WorldCard) }
  def find_card
    WorldCard.find(params.fetch(:id))
  end
end
