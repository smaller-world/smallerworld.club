# typed: true
# frozen_string_literal: true

class WorldKeysController < ApplicationController
  # == Filters ==

  allow_unauthenticated_access only: :new

  # == Actions ==

  # GET /worlds/:world_id/keys
  def index
    world = find_world
    keys_by_recipient = world.keys.includes(:recipient).group_by(&:recipient)
    render Views::WorldKeys::Index.new(world:, keys_by_recipient:)
  end

  # GET /world_keys/new?grant=...
  def new
    grant = params.fetch(:grant)
    WorldKey.verify_grant(grant) => { world_id:, color: }
    world = World.find(world_id)
    if (recipient = current_user) && recipient.world_keys.exists?(world:, color:)
      redirect_to(world)
    else
      key = WorldKey.new(world:, color:, recipient: current_user)
      render Views::WorldKeys::New.new(key:)
    end
  end

  # POST /worlds/:world_id/keys
  def create
    current_user = current_user!
    grant = params.require(:world_key).fetch(:grant)
    WorldKey.verify_grant(grant) => { world_id:, color: }
    world = World.find(world_id)
    key = current_user.world_keys.build(world_id:, color:)
    if key.save
      redirect_to(world, notice: "welcome to #{world.name}!")
    else
      flash.now.alert = key.errors.full_messages.first
      render(
        Views::WorldKeys::New.new(key:),
        status: :unprocessable_content,
      )
    end
  end

  # DELETE /world_keys/:id
  def destroy
    key = find_key
    authorize!(key)
    key.destroy!
    redirect_to([ key.world!, WorldKey ])
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
