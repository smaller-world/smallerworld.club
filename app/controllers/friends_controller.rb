# typed: true
# frozen_string_literal: true

class FriendsController < ApplicationController
  # == Filters ==

  before_action :authenticate_user!, only: %i[create destroy]
  before_action :authenticate_friend!, only: :notification_settings

  # == Actions ==

  # GET /friends/:id/notification_settings[?friend_token=...]
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

  # PUT /friends/:id[?friend_token=...]
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

  sig { params(scope: Friend::PrivateRelation).returns(Friend) }
  def find_friend(scope: Friend.all)
    scope.find(params.fetch(:id))
  end
end
