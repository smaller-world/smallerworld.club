# typed: true
# frozen_string_literal: true

class WorldKeyWorldVisitsController < ApplicationController
  # == Actions ==

  # POST /world_key/:world_key_id/world_visit
  def create
    respond_to do |format|
      format.html do
        world_key = find_world_key
        authorize!(world_key, to: :track_world_visit?)
        if world_key.record_world_visit
          render turbo_stream: append_log_message(
            "Tracked world visit for world key: #{world_key.id}",
          )
        else
          message = "Failed to track world visit for world key: #{world_key.id}"
          if (error = world_key.errors.full_messages.first)
            message += " (#{error})"
          end
          Sentry.capture_message(message)
          render(
            turbo_stream: append_log_message(message, level: :error),
            status: :unprocessable_content,
          )
        end
      end
    end
  end

  private

  # == Helpers ==

  sig { returns(WorldKey) }
  def find_world_key
    WorldKey.find(params.fetch(:world_key_id))
  end
end
