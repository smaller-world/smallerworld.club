# typed: true
# frozen_string_literal: true

class WorldKeyGrantsController < ApplicationController
  # == Actions ==

  # GET /worlds/:world_id/key_grants/new
  def new
    world = find_world
    key_color = params[:key_color]&.to_sym
    render Views::WorldKeyGrants::New.new(world:, key_color:)
  end

  private

  # == Helpers ==

  sig { returns(World) }
  def find_world
    World.friendly.find(params.fetch(:world_id))
  end
end
