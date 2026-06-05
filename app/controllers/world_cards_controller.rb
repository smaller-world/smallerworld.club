# typed: true
# frozen_string_literal: true

class WorldCardsController < ApplicationController
  # == Configuration ==

  allow_unauthenticated_access only: [ :show, :create, :unlinked ]
  skip_verify_authorized only: [ :show, :create, :unlinked ]

  # == Actions ==

  # GET /world_cards/:id
  def show
    card = find_card
    pkpass_path = card.passkit_generator.generate_and_sign
    send_file(
      pkpass_path,
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
          cardholder: Current.user,
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

  # GET /world_cards/unlinked?pass_serial_numbers[]=...
  def unlinked
    respond_to do |format|
      if turbo_frame_request?
        format.html do
          pass_serial_numbers = params.fetch(:pass_serial_numbers)
          passes = Passkit::Pass.where(serial_number: pass_serial_numbers)
          world_cards = WorldCard.unlinked.where(pass: passes)
          render Views::WorldCards::Unlinked.new(world_cards:)
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
