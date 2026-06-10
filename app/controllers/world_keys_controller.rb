# typed: true
# frozen_string_literal: true

class WorldKeysController < ApplicationController
  # == Actions ==

  # GET /worlds/:world_id/keys
  def show
    respond_to do |format|
      format.html do
        world = find_world
        authorize!(world, to: :manage?)
        keys_by_recipient = authorized_scope(world.keys)
          .accepted
          .includes(:recipient)
          .group_by(&:recipient)
        render Views::WorldKeys::Show.new(world:, keys_by_recipient:)
      end
    end
  end

  # GET /worlds/:world_id/keys/edit
  def edit
    world = find_world
    authorize!(world)
    render Views::WorldKeys::Edit.new(world:)
  end

  # PUT/PATCH /worlds/:world_id/keys/:id
  def update
    respond_to do |format|
      format.html do
        world = find_world
        authorize!(world)
        world_params = params.expect(world: [ :name, :blurb, :icon ])
        if world.update(**world_params)
          refresh_or_redirect_to(
            [ world, :keys ],
            notice: "your world key labels were saved",
          )
        else
          render Views::WorldKeys::Edit.new(world:), status: :unprocessable_content
        end
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
        redirect_to([ key.world!, :keys ])
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
