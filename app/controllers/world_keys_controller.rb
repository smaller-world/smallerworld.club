# typed: true
# frozen_string_literal: true

class WorldKeysController < ApplicationController
  # == Actions ==

  # GET /worlds/:world_id/keys
  def index
    world = find_world
    keys_by_recipient = world.keys.accepted.includes(:recipient).group_by(&:recipient)
    render Views::WorldKeys::Index.new(world:, keys_by_recipient:)
  end

  # POST /world_keys/accept
  def accept
    current_user = current_user!
    grant = params.require(:world_key).fetch(:grant)
    WorldKey.verify_grant(grant) => { world_id:, color: }
    world = World.find(world_id)
    key = current_user.world_keys.build(
      world_id:,
      color:,
      accepted_at: Time.current,
    )
    if key.save
      redirect_to(world, notice: "welcome to #{world.name}!")
    else
      flash.now.alert = key.errors.full_messages.first
      render(
        Views::WorldKeyGrants::Show.new(key:),
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
