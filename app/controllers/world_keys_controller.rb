# typed: true
# frozen_string_literal: true

class WorldKeysController < ApplicationController
  # == Actions ==

  # GET /worlds/:world_id/keys
  def index
    respond_to do |format|
      format.html do
        world = find_world
        authorize!(world, to: :manage?)
        keys_by_recipient = world.keys
          .accepted
          .includes(:recipient)
          .group_by(&:recipient)
        render Views::WorldKeys::Index.new(world:, keys_by_recipient:)
      end
    end
  end

  # DELETE /world_keys/:id
  def destroy
    respond_to do |format|
      format.html do
        key = find_key
        authorize!(key)
        key.destroy!
        redirect_to([ key.world!, WorldKey ])
      end
    end
  end

  private

  # == Helpers ==

  sig { returns(World) }
  def find_world
    World.friendly.find(params.fetch(:world_id))
  end

  sig { returns(WorldKey) }
  def find_key
    WorldKey.find(params.fetch(:id))
  end
end
