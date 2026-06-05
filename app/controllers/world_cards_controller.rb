# typed: true
# frozen_string_literal: true

class WorldCardsController < ApplicationController
  # == Configuration ==

  allow_unauthenticated_access
  skip_verify_authorized only: :unlinked

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
    authorize!(card, to: :show?)
    pkpass_path = card.passkit_generator.generate_and_sign
    send_file(
      pkpass_path,
      type: "application/vnd.apple.pkpass",
      disposition: "attachment",
    )
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
