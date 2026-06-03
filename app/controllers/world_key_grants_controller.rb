# typed: true
# frozen_string_literal: true

class WorldKeyGrantsController < ApplicationController
  # == Configuration ==

  allow_unauthenticated_access only: :show
  skip_verify_authorized only: :show

  # == Actions ==

  # GET /world_invitations/:grant
  def show
    grant = params.fetch(:grant)
    WorldKey.verify_grant(grant) => { world_id:, color: }
    world = World.find(world_id)
    if (recipient = current_user) && recipient.world_keys.exists?(world:, color:)
      redirect_to(world)
    else
      key_or_card = if hotwire_native_app?
        world.keys.build(color:, recipient: current_user)
      else
        world.cards.build(granted_key_color: color, cardholder: current_user)
      end
      render Views::WorldKeyGrants::Show.new(key_or_card:)
    end
  end

  # GET /worlds/:world_id/key_grants/new
  def new
    world = find_world
    authorize!(world, to: :manage?)
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
