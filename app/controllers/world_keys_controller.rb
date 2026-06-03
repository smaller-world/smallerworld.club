# typed: true
# frozen_string_literal: true

class WorldKeysController < ApplicationController
  # == Configuration ==

  skip_verify_authorized only: :accept

  # == Actions ==

  # GET /worlds/:world_id/keys
  def index
    respond_to do |format|
      format.html do
        world = find_world
        authorize!(world, to: :manage?)
        keys_by_recipient = world.keys.accepted.includes(:recipient).group_by(&:recipient)
        render Views::WorldKeys::Index.new(world:, keys_by_recipient:)
      end
    end
  end

  # POST /world_keys/accept
  def accept
    respond_to do |format|
      format.html do
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
            Views::WorldKeyGrants::Show.new(key_or_card: key),
            status: :unprocessable_content,
          )
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
