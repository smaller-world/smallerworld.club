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
        @page_title = "your smaller universe" unless hotwire_native_app?
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
      end
    end
  end
end
