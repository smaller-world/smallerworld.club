# typed: true
# frozen_string_literal: true

class WorldKeyGrantsController < ApplicationController
  # == Filters ==

  allow_unauthenticated_access only: :show

  # == Actions ==

  # GET /world_key_grants/:grant
  def show
    grant = params.fetch(:grant)
    WorldKey.verify_grant(grant) => { world_id:, color: }
    world = World.find(world_id)
    if (recipient = current_user) && recipient.world_keys.exists?(world:, color:)
      redirect_to(world)
    else
      key = WorldKey.new(world:, color:, recipient: current_user)
      render Views::WorldKeyGrants::Show.new(key:)
    end
  end

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
