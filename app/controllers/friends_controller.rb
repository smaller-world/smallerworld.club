# typed: true
# frozen_string_literal: true

class FriendsController < ApplicationController
  # == Filters ==

  before_action :authenticate_user!, only: %i[create invite]
  before_action :authenticate_friend!, except: %i[create invite]

  # == Actions ==

  # GET /@:world_id/friends/invite
  def invite
    respond_to do |format|
      format.html do
        @world = find_world
        @qr = RQRCode::QRCode.new(
          shortlinked.join_world_url(token: @world.generate_join_token),
        )
      end
    end
  end


  # GET /friends/:token/notification_settings
  def notification_settings
    respond_to do |format|
      format.json do
        current_friend = authenticate_friend!
        render(json: {
          "notificationSettings" =>
            FriendNotificationSettingsSerializer.one(current_friend),
        })
      end
    end
  end


  # POST /friends
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
            world_path(@world, friend_token: @friend.access_token),
            status: :see_other,
          )
        else
          render "worlds/join", status: :unprocessable_content
        end
      end
    end
  end

  # PUT /friends/:token
  def update
    respond_to do |format|
      format.json do
        current_friend = authenticate_friend!
        friend_params = params.expect(friend: [ :subscribed_post_types ])
        if current_friend.update(friend_params)
          render(json: {
            "notificationSettings" =>
              FriendNotificationSettingsSerializer.one(current_friend),
          })
        else
          render(
            json: { errors: current_friend.form_errors },
            status: :unprocessable_content,
          )
        end
      end
    end
  end

  private

  # == Helpers ==

  sig { returns(World) }
  def find_world
    World.friendly.find(params.fetch(:world_id))
  end
end
