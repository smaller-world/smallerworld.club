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
          current_user = current_user!
          pass_serial_numbers = params.require(:user)
            .fetch(:world_card_pass_serial_numbers)
          passes = Passkit::Pass.where(serial_number: pass_serial_numbers)
          world_cards = WorldCard.where(pass: passes)
          current_user.update!(world_cards:)
          refresh_or_redirect_to(home_path)
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
