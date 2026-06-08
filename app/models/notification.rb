# typed: strict
# frozen_string_literal: true

# rubocop:disable Layout/LineLength, Lint/RedundantCopDisableDirective
# == Schema Information
#
# Table name: notifications
#
#  id              :uuid             not null, primary key
#  delivered_at    :timestamptz
#  noticeable_type :string           not null
#  received_at     :timestamptz
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  noticeable_id   :uuid             not null
#  recipient_id    :uuid             not null
#
# Indexes
#
#  index_notifications_on_noticeable    (noticeable_type,noticeable_id)
#  index_notifications_on_recipient_id  (recipient_id)
#
# Foreign Keys
#
#  fk_rails_...  (recipient_id => users.id)
#
# rubocop:enable Layout/LineLength, Lint/RedundantCopDisableDirective
class Notification < ApplicationRecord
  # == Attributes ==

  sig { returns(T.nilable(ActiveSupport::Duration)) }
  attr_accessor :delivery_delay

  sig { returns(T::Boolean) }
  def delivered? = delivered_at?

  sig { returns(T::Boolean) }
  def received? = received_at?

  # == Associations ==

  belongs_to :noticeable, polymorphic: true
  belongs_to :recipient,
    class_name: "User",
    inverse_of: :received_notifications

  sig { returns(User) }
  def recipient!
    recipient or raise ActiveRecord::RecordNotFound, "Missing recipient"
  end

  sig { returns(Noticeable) }
  def noticeable!
    noticeable or
      raise ActiveRecord::RecordNotFound, "Missing associated noticeable"
  end

  # == Callbacks ==

  after_create :deliver_later, unless: :delivered?

  # == Scopes ==

  # scope :delivered, -> { where.not(delivered_at: nil) }
  # scope :undelivered, -> { where(delivered_at: nil) }

  # == Delivery Token ==

  generates_token_for :delivery do
    delivered?
  end

  sig { returns(T.nilable(String)) }
  def generate_delivery_token
    generate_token_for(:delivery) unless delivered?
  end

  sig { params(token: String).returns(T.nilable(Notification)) }
  def self.find_by_delivery_token(token)
    find_by_token_for(:delivery, token)
  end

  # == Delivery ==

  sig { void }
  def deliver
    recipient = recipient!
    message = self.message
    apple_data = {
      aps: { "mutable-content" => 1 },
    }
    if (target_url = message.target_url)
      apple_data["target_url"] = target_url
    end
    if (world = message.world) && (variant = world.notification_icon_variant)
      apple_data["icon_url"] = Rails.application.routes.url_helpers
        .rails_representation_path(variant, only_path: true)
    end
    device_notification = DevicePushNotification
      .with_apple(apple_data)
      .new(
        thread_id: message.world&.id,
        title: message.title,
        body: message.body,
        badge: recipient.notifications_received_since_last_cleared.count,
      )
    recipient.devices.find_each do |device|
      device_notification.deliver_to(device)
    end
    update!(delivered_at: Time.current)
  end

  sig { params(options: T.untyped).void }
  def deliver_later(**options)
    DeliverNotificationJob.set(wait: delivery_delay, **options).perform_later(self)
  end

  # == Methods ==

  sig { returns(Message) }
  def message
    noticeable!.notification_message(recipient: recipient!)
  end

  sig { void }
  def mark_as_received!
    update!(received_at: Time.current)
  end
end
