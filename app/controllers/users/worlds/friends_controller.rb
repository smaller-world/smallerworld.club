# typed: true
# frozen_string_literal: true

module Users::Worlds
  class FriendsController < ApplicationController
    # == Actions ==

    # GET /world/friends
    def index
      respond_to do |format|
        format.html do
          @world = current_world or next redirect_to(
            new_registration_path,
            notice: "create a world to continue",
          )
          if hotwire_native_app?
            @page_title = "your friends"
            @friends = @world.friends
              .with_push_registrations
              .reverse_chronological
          else
            pending_invitations = @world.invitations.pending.count
            render(
              inertia: "UserWorldFriendsPage",
              world_theme: @world.theme,
              props: {
                world: WorldSerializer.one(@world),
                "pendingInvitationsCount" => pending_invitations,
              },
            )
          end
        end
        format.json do
          world = current_world!
          friends = world.friends
            .with_active_activity_coupons
            .with_push_registrations
            .reverse_chronological
          render(json: {
            friends: UserWorldFriendProfileSerializer.many(friends),
          })
        end
      end
    end

    # GET /world/friends/invite
    def invite
      respond_to do |format|
        format.html do
          @world = current_world!
          @qr_code = RQRCode::QRCode.new(
            shortlinked.join_world_url(token: @world.generate_join_token),
          )
        end
      end
    end

    # PUT /world/friends/:id
    def update
      respond_to do |format|
        format.json do
          friend = find_friend
          authorize!(friend)
          friend_params = params.expect(friend: %i[emoji name])
          if friend.update(friend_params)
            render(json: {
              friend: FriendSerializer.one(friend),
            })
          else
            render(
              json: {
                errors: friend.form_errors,
              },
              status: :unprocessable_content,
            )
          end
        end
      end
    end

    # POST /world/friends/:id/pause
    def pause
      respond_to do |format|
        format.json do
          friend = find_friend
          authorize!(friend)
          if friend.update(paused_since: Time.current)
            render(json: {
              friend: FriendSerializer.one(friend),
            })
          else
            render(
              json: { errors: friend.form_errors },
              status: :unprocessable_content,
            )
          end
        end
      end
    end

    # POST /world/friends/:id/unpause
    def unpause
      respond_to do |format|
        format.json do
          friend = find_friend
          authorize!(friend)
          if friend.update(paused_since: nil)
            render(json: {
              friend: FriendSerializer.one(friend),
            })
          else
            render(
              json: {
                errors: friend.form_errors,
              },
              status: :unprocessable_content,
            )
          end
        end
      end
    end

    # POST /world/friends
    def create
      respond_to do |format|
        format.html do
          current_user = authenticate_user!
          friend_params = params.expect(friend: %i[
            join_token
            name
            emoji
            time_zone
          ])
          join_token = friend_params.delete(:join_token)
          @world = World.find_by_join_token(join_token) or
            raise "Invalid join token"
          @friend = @world.friends.build(
            phone_number: current_user.phone_number,
            **friend_params,
          )
          if @friend.save
            redirect_to(
              world_path(
                @world,
                friend_token: @friend.access_token,
                emulate_native_app: 1,
              ),
              notice: "you're in!",
              status: :see_other,
            )
          else
            render "worlds/join", status: :unprocessable_content
          end
        end
      end
    end

    # DELETE /world/friends/:id
    def destroy
      @friend = find_friend
      authorize!(@friend)
      respond_to do |format|
        format.json do
          @friend.destroy!
          render(json: {})
        end
        format.turbo_stream do
          @friend.destroy
        end
      end
    end

    # GET /world/friends/:id/invitation
    def invitation
      respond_to do |format|
        format.json do
          friend = find_friend
          authorize!(friend)
          invitation = friend.invitation || scoped do
            created_at = friend.created_at
            friend.transaction do |invitation|
              invitation = friend.create_invitation!(
                world: friend.world!,
                invitee_name: friend.name,
                invitee_emoji: friend.emoji,
                created_at:,
                updated_at: created_at,
                join_request_id: friend.deprecated_join_request_id,
              )
              friend.save!
              invitation
            end
          end
          render(json: {
            invitation: UserWorldInvitationSerializer.one(invitation),
          })
        end
      end
    end

    private

    # == Helpers ==

    sig { params(scope: Friend::PrivateRelation).returns(Friend) }
    def find_friend(scope: Friend.all)
      scope.find(params.fetch(:id))
    end
  end
end
