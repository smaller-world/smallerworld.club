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
#
# Foreign Keys
#
#  fk_rails_...  (owner_id => users.id)
#
# rubocop:enable Layout/LineLength, Lint/RedundantCopDisableDirective
class Device < ApplicationRecord
  extend Enumerize
  extend T::Sig

  include ActiveSupport::Rescuable

  # == Attributes ==

  enumerize :platform, in: [ :apple, :google ]

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

  validates :identifier, uniqueness: true

  # Remove push token if token is invalid
  rescue_from ActionPushNative::TokenError, with: :remove_push_token!

  # == Scopes ==

  scope :notifiable, -> { where.not(push_token: nil) }

  # == Methods ==

  sig { params(notification: DevicePushNotification).void }
  def push(notification)
    notification.token = push_token!
    ActionPushNative.service_for(platform, notification).push(notification)
    tag_logger do
      Rails.logger.info("Pushed notification to device #{id}")
    end
  rescue => error
    rescue_with_handler(error) || raise
  end

  sig { void }
  def send_test_notification
    url_helpers = Rails.application.routes.url_helpers
    notification = DevicePushNotification
      .with_data(target_url: url_helpers.home_path)
      .new(
        title: "test notification",
        body: "this is a test notification. if you are seeing this, then " \
          "your push notifications are working!",
      )
    notification.deliver_to(self)
  end

  private

  sig { void }
  def remove_push_token!
    update!(push_token: nil)
  end
end
