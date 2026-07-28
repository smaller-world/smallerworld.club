# typed: strict
# frozen_string_literal: true

# rubocop:disable Layout/LineLength, Lint/RedundantCopDisableDirective
# == Schema Information
#
# Table name: devices
#
#  id         :uuid             not null, primary key
#  identifier :string           not null
#  name       :string
#  platform   :string           not null
#  push_token :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  owner_id   :uuid
#
# Indexes
#
#  index_devices_on_identifier  (identifier) UNIQUE
#  index_devices_on_owner_id    (owner_id)
#  index_devices_on_push_token  (push_token) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (owner_id => users.id)
#
# rubocop:enable Layout/LineLength, Lint/RedundantCopDisableDirective
class Device < ApplicationRecord
  extend Enumerize

  # == Attributes ==

  enumerize :platform, in: DeviceDetection::HOTWIRE_NATIVE_PLATFORMS

  sig { returns(String) }
  def push_token!
    push_token or raise ApplicationError, "Missing push token"
  end

  # == Associations ==

  belongs_to :owner, class_name: "User", optional: true
  has_many :world_cards, dependent: :destroy
  has_many :world_card_passes,
    through: :world_cards,
    source: :pass

  sig { returns(User) }
  def owner!
    owner or raise ActiveRecord::RecordNotFound, "Missing owner"
  end

  # == Validations ==

  validates :identifier, presence: true, uniqueness: true

  # == Hooks ==

  # A duplicate push token means the same physical device re-registered, so
  # supersede the stale rows instead of failing the save.
  before_save :remove_devices_with_duplicate_push_tokens!,
    if: [ :push_token_changed?, :push_token? ]

  # == Scopes ==

  scope :notifiable, -> { where.not(push_token: nil) }

  # == Methods ==

  sig { returns(Symbol) }
  def action_push_native_platform
    case platform
    when "ios", "ios_app_on_mac"
      :apple
    else
      platform.to_sym
    end
  end

  sig { params(notification: DevicePushNotification).void }
  def push(notification)
    notification.token = push_token!
    ActionPushNative
      .service_for(action_push_native_platform, notification)
      .push(notification)
    tag_logger do
      Rails.logger.info("Pushed notification to device #{id}")
    end
  rescue ActionPushNative::TokenError => error
    tag_logger do
      Rails.logger.warn("Removing push token for device #{id}: #{error.message}")
    end
    update!(push_token: nil)
  end

  sig { params(world: T.nilable(World)).void }
  def send_test_notification(world: nil)
    url_helpers = Rails.application.routes.url_helpers
    apple_data = T.let({}, T::Hash[T.untyped, T.untyped])
    if world
      apple_data.deep_merge!({ aps: { "mutable-content" => 1 } })
      apple_data["icon_url"] =
        Rails.application.routes.url_helpers.rails_representation_path(
          world.notification_icon_variant,
          only_path: true,
        )
    end
    notification = DevicePushNotification
      .with_data(target_url: url_helpers.home_path)
      .with_apple(apple_data)
      .new(
        title: "test notification",
        body: "if you are seeing this, then your push notifications are working!",
        thread_id: world&.id,
      )
    notification.deliver_to(self)
  end

  private

  # == Callbacks ==

  sig { void }
  def remove_devices_with_duplicate_push_tokens!
    if (push_token = self.push_token)
      Device.where(push_token:).destroy_all
    end
  end
end
