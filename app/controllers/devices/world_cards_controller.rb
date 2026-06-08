# typed: true
# frozen_string_literal: true

class Devices::WorldCardsController < ApplicationController
  # == Configuration ==

  skip_verify_authorized

  # == Actions ==

  # # PUT /device/world_cards
  # def update
  #   respond_to do |format|
  #     format.turbo_stream do
  #       current_device = Current.device!
  #       pass_serial_numbers = params.require(:device)
  #         .fetch(:world_card_pass_serial_numbers)
  #       world_cards = WorldCard
  #         .joins(:pass)
  #         .where(passkit_passes: { serial_number: pass_serial_numbers })
  #       previous_world_card_ids = current_device.world_card_ids.to_set
  #       current_device.update!(world_cards:)
  #       if current_device.world_card_ids.to_set != previous_world_card_ids
  #         refresh_or_redirect_to(home_path)
  #       else
  #         render turbo_stream: append_log_message(
  #           "No new cards linked to device",
  #           level: :info,
  #         )
  #       end
  #     rescue => error
  #       render turbo_stream: append_log_message(
  #         "Failed to link cards to device: #{error.message}",
  #         level: :error,
  #       )
  #     end
  #   end
  # end
end
