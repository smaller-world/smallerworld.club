# typed: true
# frozen_string_literal: true

class WorldCardsController < ApplicationController
  # == Configuration ==

  allow_unauthenticated_access only: [ :show, :download ]

  # == Actions ==

  # GET /world_cards/:id
  def show
    card = find_card
    authorize!(card)
    render Views::WorldCards::Show.new(card:)
  end

  # GET /world_cards/:id/download
  def download
    card = find_card
    authorize!(card)
    pkpass_path = card.passkit_generator.generate_and_sign
    send_file(
      pkpass_path,
      type: "application/vnd.apple.pkpass",
      disposition: "attachment",
    )
  end

  # POST /world_cards/:id/claim
  def claim
    current_user = Current.user!
    current_device = Current.device!
    card = find_card
    authorize!(card)
    world = card.world!
    begin
      card.update!(device: current_device, cardholder: current_user)
      redirect_to(
        world,
        notice: "card successfully linked to your account",
        status: :see_other,
      )
    rescue => error
      redirect_to(world, alert: error, status: :see_other)
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
