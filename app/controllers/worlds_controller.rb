# typed: true
# frozen_string_literal: true

class WorldsController < ApplicationController
  include RendersWorldFavicons
  include LoadsWorldPosts

  # == Constants ==

  POSTS_PER_PAGE = 5

  # == Filters ==

  before_action :authenticate_user!, only: :join

  # == Actions ==

  # GET /@:id?intent=(join|install)
  #          &manifest_icon_type=(generic|user)
  #          &friend_token=...
  def show
    respond_to do |format|
      @world = find_world(scope: World.includes(:owner))
      format.html do
        if hotwire_native_app?
          @pagy, @posts = paginated_world_posts(@world)
        else
          if (current_user = self.current_user)
            invitation_requested = @world
              .join_requests
              .exists?(phone_number: current_user.phone_number)
          end
          if (friend = current_friend)
            reply_to_number = @world.reply_to_number
            last_sent_encouragement = friend.latest_visible_encouragement
          end
          props = {
            world: WorldProfileSerializer.one(@world),
            "replyToNumber" => reply_to_number,
            "lastSentEncouragement" => EncouragementSerializer
              .one_if(last_sent_encouragement),
            "invitationRequested" => invitation_requested || false,
          }
          unless params[:manifest_icon_type] == "generic"
            props["faviconLinks"] = world_favicon_links(@world)
          end
          render(inertia: "WorldPage", world_theme: @world.theme, props:)
        end
      end
      format.turbo_stream do
        @pagy, @posts = paginated_world_posts(@world)
      end
    end
  end

  # GET /worlds/:token/join
  def join
    respond_to do |format|
      format.html do
        current_user = authenticate_user!
        token = params.fetch(:token)
        if (@world = World.find_by_join_token(token))
          @friend = @world.friends.build(
            phone_number: current_user.phone_number,
            name: current_user.name,
          )
        end
      end
    end
  end


  private

  # == Helpers ==

  sig { params(scope: World::PrivateRelation).returns(World) }
  def find_world(scope: World.all)
    scope.friendly.find(params.fetch(:id))
  end
end
