# typed: true
# frozen_string_literal: true

class UniversesController < ApplicationController
  # == Filters ==

  before_action :authenticate_user!

  # == Actions ==

  # GET /universe
  def show
    respond_to do |format|
      format.html do
        @page_title = "your smaller universe"
        current_user = authenticate_user!
        associated_friends = scoped do
          friends = current_user.associated_friends
          if (world = current_user.world)
            friends.where.not(world_id: world.id)
          else
            friends
          end
        end
        @worlds = World
          .includes(:owner)
          .where(id: associated_friends.select(:world_id))
          .or(World.where(owner_id: current_user.id))
          .left_outer_joins(:posts)
          .group("worlds.id")
          .select(
            "worlds.*",
            "MAX(posts.created_at) AS last_post_created_at",
          )
          .order("last_post_created_at DESC NULLS LAST")
          .with_attached_icon
        @access_tokens_by_world_id = associated_friends
          .select("DISTINCT ON (world_id) world_id, access_token")
          .map { |friend| [ friend.world_id, friend.access_token ] }
          .to_h
      end
    end
  end
end
