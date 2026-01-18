# typed: true
# frozen_string_literal: true

module Users
  class WorldsController < Worlds::ApplicationController
    include RendersManifestIcons
    include RendersWorldFavicons

    # == Constants ==

    POSTS_PER_PAGE = 5

    # == Actions ==

    # GET /world?intent=(installation_instructions|install)
    def show
      respond_to do |format|
        format.html do
          @world = current_world or next redirect_to(new_registration_path)
          if hotwire_native_app?
            set_posts(@world)
            render "worlds/show"
          else
            latest_friends = @world.friends
              .reverse_chronological
              .where.associated(:push_registrations)
              .distinct
              .select(:id, :created_at, :emoji)
              .first(3)
            if latest_friends.size < 3
              latest_friends += @world.friends
                .reverse_chronological
                .where.missing(:push_registrations)
                .distinct
                .select(:id, :created_at, :emoji)
                .first(3 - latest_friends.size)
            end
            user_created_posts = @world.posts
              .where.not(id: @world.posts.auto_generated.select(:id))
            render(
              inertia: "UserWorldPage",
              world_theme: @world.theme,
              props: {
                "faviconLinks" => world_favicon_links(
                  @world,
                  except_apple_touch_icon: true,
                ),
                world: WorldSerializer.one(@world),
                "latestFriendEmojis" => latest_friends.map(&:emoji),
                "pendingJoinRequests" => @world.join_requests.pending.count,
                "pendingInvitations" => @world.invitations.pending.count,
                "hasAtLeastOneUserCreatedPost" =>
                  user_created_posts.exists?,
              },
            )
          end
        end
        format.turbo_stream do
          @world = current_world!
          set_posts(@world)
          render "worlds/show"
        end
      end
    end

    sig { params(world: World).void }
    private def set_posts(world)
      scope = world.posts
        .order(created_at: :desc, id: :asc)
        .with_attached_images
        .with_quoted_post_and_attached_images
        .with_rich_text_body_and_embeds
      @pagy, @posts = pagy(:keyset, scope, limit: POSTS_PER_PAGE)
    end

    # GET /world/edit
    def edit
      respond_to do |format|
        format.html do
          world = current_world or next redirect_to(new_registration_path)
          render(
            inertia: "UserEditWorldPage",
            world_theme: world.theme,
            props: {
              world: WorldSerializer.one(world),
            },
          )
        end
      end
    end

    # PUT /world
    def update
      respond_to do |format|
        format.json do
          world = current_world!
          world_params = params.expect(world: [
            :icon,
            :theme,
            :hide_stats,
            :hide_neko,
            :allow_friend_sharing,
            owner_attributes: %i[name allow_space_replies],
          ])
          if world.update(**world_params)
            owner = world.owner!
            render(json: {
              world: WorldSerializer.one(world),
              owner: UserSerializer.one(owner),
            })
          else
            render(
              json: { errors: world.form_errors },
              status: :unprocessable_content,
            )
          end
        end
      end
    end
  end
end
