# typed: true
# frozen_string_literal: true

module Devices
  class WorldCardsController < ApplicationController
    # == Configuration ==

    skip_verify_authorized

    # == Actions ==

    # PUT /device/world_cards
    def update
      respond_to do |format|
        format.turbo_stream do
          current_device = Current.device!
          pass_serial_numbers = params.require(:device)
            .fetch(:world_card_pass_serial_numbers)
          passes = Passkit::Pass.where(serial_number: pass_serial_numbers)
          world_cards = WorldCard.where(pass: passes)
          current_device.update!(world_cards:)
          refresh_or_redirect_to(home_path)
        rescue => error
          render turbo_stream: append_log_message(
            "Failed to link cards to device: #{error.message}",
            level: :error,
          )
        end
      end
    end
  end
end
