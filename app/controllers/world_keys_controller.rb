# typed: true
# frozen_string_literal: true

class WorldKeysController < ApplicationController
  # == Filters ==

  allow_unauthenticated_access only: :receive

  # == Actions ==

  # GET /worlds/:world_id/keys
  def index
    raise NotImplementedError
  end

  # GET /worlds/:world_id/keys/share
  def share
    world = find_world
    key_color = params[:key_color]&.to_sym
    render Views::WorldKeys::Share.new(world:, key_color:)
  end

  # GET /world_keys/receive/:grant
  def receive
    grant = params.fetch(:grant)
    WorldKey.verify_grant(grant) => { world_id:, color: }
    world = World.find(world_id)
    if (recipient = current_user) && recipient.world_keys.exists?(world:, color:)
      redirect_to(world)
    else
      world_key = WorldKey.new(world:, color:, recipient: current_user)
      render Views::WorldKeys::Receive.new(world_key:)
    end
  end

  # POST /world_keys/accept
  def accept
    current_user = current_user!
    grant = params.require(:world_key).fetch(:grant)
    WorldKey.verify_grant(grant) => { world_id:, color: }
    world_key = current_user.world_keys.build(world_id:, color:)
    if world_key.save
      redirect_to(world_key.world!)
    else
      flash.now.alert = world_key.errors.full_messages.first
      render(
        Views::WorldKeys::Receive.new(world_key:),
        status: :unprocessable_content,
      )
    end
  end

  private

  # == Helpers ==

  sig { returns(World) }
  def find_world
    World.friendly.find(params.fetch(:world_id))
  end
end
