# typed: true
# frozen_string_literal: true

class WorldSettingsController < ApplicationController
  # == Actions ==

  # GET /worlds/:id/settings
  def show
    world = find_world
    authorize!(world, to: :show?, with: WorldSettingsPolicy)
    render Views::WorldSettings::Show.new(world:)
  end

  private

  # == Helpers ==

  sig { returns(World) }
  def find_world
    World.friendly.find(params.fetch(:world_id))
  end
end
