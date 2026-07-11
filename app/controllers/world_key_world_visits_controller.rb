# typed: true
# frozen_string_literal: true

class WorldKeyWorldVisitsController < ApplicationController
  include RenderJsonError

  # == Actions ==

  # POST /world_key/:world_key_id/world_visit
  def create
    respond_to do |format|
      format.json do
        world_key = find_world_key
        authorize!(world_key, to: :record_world_visit?)
        begin
          world_key.record_world_visit!
          render(json: { world_id: world_key.world_id })
        rescue => error
          Sentry.capture_exception(error)
          render_json_error(error)
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
