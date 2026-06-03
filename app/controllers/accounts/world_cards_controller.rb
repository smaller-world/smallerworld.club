# typed: true
# frozen_string_literal: true

module Accounts
  class WorldCardsController < ApplicationController
    # == Configuration ==

    skip_verify_authorized

    # == Actions ==

    # PUT /accounts/world_card_passes
    def update
      respond_to do |format|
        format.turbo_stream do
          user = current_user!
          serial_numbers = params.require(:user).fetch(:world_card_pass_serial_numbers)
          passes = Passkit::Pass.where(serial_number: serial_numbers)
          world_cards = WorldCard.where(pass: passes)
          user.update(world_cards:)
          render turbo_stream: [
            append_log_message(
              "Linked WorldCards to user: #{world_cards.pluck(:id)}",
              level: :info,
            ),
            turbo_stream.refresh(scroll: "preserve"),
          ]
        rescue => error
          render turbo_stream: append_log_message(
            "Failed to link WorldCards to user: #{error.message}",
            level: :error,
          )
        end
      end
    end
  end
end
