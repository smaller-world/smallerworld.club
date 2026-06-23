# typed: true
# frozen_string_literal: true

class WorldCardKeyGrantsController < ApplicationController
  # == Actions ==

  # GET /world_cards/:card_id/key_grant
  def show
    card = find_card
    authorize!(card)
    world = card.world!
    if card.cardholder
      redirect_to(world)
    else
      render Views::WorldCardKeyGrants::Show.new(card:)
    end
  end

  # POST /world_cards/:card_id/key_grant/accept
  def accept
    respond_to do |format|
      format.html do
        current_user = Current.user!
        current_device = Current.device!
        card = find_card
        authorize!(card)
        key_color = card.granted_key_color or
          raise ApplicationError, "Missing granted key color"

        world = card.world!
        begin
          ActiveRecord::Base.transaction do
            card.update!(cardholder: current_user, device: current_device)
            current_user.world_keys.create!(
              world:,
              color: key_color,
              accepted_at: Time.current,
            )
          end
          redirect_to([ world, celebrate: true ], status: :see_other)
        rescue => error
          flash.now.alert = "Failed to accept key: #{error}"
          render(
            Views::WorldCardKeyGrants::Show.new(card:),
            status: :unprocessable_content,
          )
        end
      end
    end
  end

  private

  # == Helpers ==

  sig { returns(WorldCard) }
  def find_card
    WorldCard.find(params.fetch(:card_id))
  end
end
