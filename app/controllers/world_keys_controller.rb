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
        render Views::WorldKeys::Index.new(world:)
      end
    end
  end

  # GET /world_keys/:id/edit
  def edit
    respond_to do |format|
      format.html do
        world_key = find_world_key
        authorize!(world_key)
        render Views::WorldKeys::Edit.new(world_key:)
      end
    end
  end

  # PUT/PATCH /world_keys/:id
  def update
    respond_to do |format|
      format.html do
        world_key = find_world_key
        authorize!(world_key)
        world_key_params = params.expect(world_key: [ granted_post_type_ids: [] ])
        world_key.update!(world_key_params)
        refresh_or_redirect_to([ world_key.world, :keys ], status: :see_other)
      end
    end
  end

  # DELETE /world_keys/:id
  def destroy
    respond_to do |format|
      format.html do
        world_key = find_world_key
        world = world_key.world!
        authorize!(world_key)
        world_key.destroy!
        redirect_to([ world, :keys ], status: :see_other)
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
  def find_world_key
    WorldKey.find(params.fetch(:id))
  end
end
