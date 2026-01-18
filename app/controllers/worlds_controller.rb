# typed: true
# frozen_string_literal: true

class WorldsController < ApplicationController
  include RendersWorldFavicons

  # == Constants ==

  POSTS_PER_PAGE = 5

  # == Actions ==

  # GET /@:id?intent=(join|install)
  #          &manifest_icon_type=(generic|user)
  #          &friend_token=...
  def show
    respond_to do |format|
      @world = find_world(scope: World.includes(:owner))
      format.html do
        if hotwire_native_app?
          set_posts(@world)
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
        set_posts(@world)
      end
    end
  end

  sig { params(world: World).void }
  private def set_posts(world)
    scope = authorized_scope(world.posts)
      .order(created_at: :desc, id: :asc)
      .with_attached_images
      .with_quoted_post_and_attached_images
      .with_rich_text_body_and_embeds
    @pagy, @posts = if (friend = current_friend)
      paginate_posts(scope.visible_to(friend))
    else
      paginate_posts(scope.visible_to_friends).tap do |_, paged_posts|
        paged_posts.map! do |post|
          post.visibility == :public ? post : post.becomes(MaskedPost)
        end
      end
    end
  end

  private def paginate_posts(scope)
    pagy(
      :keyset,
      scope,
      limit: POSTS_PER_PAGE,
    )
  end

  # GET /@:id/join
  def join
    respond_to do |format|
      format.html do
        world = find_world
        redirect_to(world_path(world, intent: "join"))
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
