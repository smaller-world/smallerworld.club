# typed: true
# frozen_string_literal: true

class UniversesController < ApplicationController
  # == Constants ==

  WORLDS_PER_PAGE = 24
  # WORLDS_PER_PAGE = 1

  # == Filters ==

  before_action :authenticate_user!

  # == Actions ==

  # GET /universe
  def show
    respond_to do |format|
      format.html do
        @page_title = "your smaller universe"
        @pagy, @worlds = paginated_worlds
      end
    end
  end

  # GET /universe/worlds
  def worlds
    respond_to do |format|
      format.turbo_stream do
        @pagy, @worlds = paginated_worlds
      end
    end
  end

  private

  sig { returns(Friend::PrivateRelation) }
  def associated_friends
    current_user = authenticate_user!
    friends = current_user.associated_friends
    if (world = current_user.world)
      friends.where.not(world_id: world.id)
    else
      friends
    end
  end

  sig { returns(World::PrivateRelation) }
  def associated_worlds
    current_user = authenticate_user!
    World
      .left_outer_joins(:posts)
      .joins(:friends)
      .where(friends: { phone_number: current_user.phone })
      .and(
        World
          .where(id: associated_friends.select(:world_id))
          .or(World.where(owner_id: current_user.id)),
      )
      .group("worlds.id")
      .select(
        "worlds.*",
        "MAX(posts.created_at) AS last_post_created_at",
        "ANY_VALUE(friends.access_token) AS friend_token",
      )
      .order("last_post_created_at DESC NULLS LAST, id ASC")
      .with_owner
      .with_attached_icon
  end

  sig { returns([ Pagy, T::Array[World] ]) }
  def paginated_worlds
    pagy(:countless, associated_worlds, limit: WORLDS_PER_PAGE)
  end
end
