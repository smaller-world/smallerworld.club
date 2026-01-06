# typed: true
# frozen_string_literal: true

# rubocop:disable Layout/LineLength, Lint/RedundantCopDisableDirective
# == Schema Information
#
# Table name: notifications
#
#  id                        :uuid             not null, primary key
#  delivered_at              :datetime
#  deprecated_delivery_token :string
#  noticeable_type           :string           not null
#  pushed_at                 :datetime
#  recipient_type            :string
#  created_at                :datetime         not null
#  updated_at                :datetime         not null
#  noticeable_id             :uuid             not null
#  recipient_id              :uuid
#
# Indexes
#
#  index_notifications_on_deprecated_delivery_token  (deprecated_delivery_token) UNIQUE
#  index_notifications_on_noticeable                 (noticeable_type,noticeable_id)
#  index_notifications_on_recipient                  (recipient_type,recipient_id)
#
# rubocop:enable Layout/LineLength, Lint/RedundantCopDisableDirective
class Notification < ApplicationRecord
  # == Attributes ==

  sig { returns(T.nilable(ActiveSupport::Duration)) }
  attr_accessor :push_delay

  sig { returns(T::Boolean) }
  def pushed?
    pushed_at?
  end

  sig { returns(T::Boolean) }
  def delivered? = delivered_at?

  # == Associations ==

  belongs_to :noticeable, polymorphic: true
  belongs_to :recipient,
             polymorphic: true,
             inverse_of: :received_notifications

  sig { returns(Notifiable) }
  def recipient!
    recipient or raise ActiveRecord::RecordNotFound, "Missing recipient"
  end

  sig { returns(Noticeable) }
  def noticeable!
    noticeable or
      raise ActiveRecord::RecordNotFound, "Missing associated noticeable"
  end

  # == Callbacks ==

  after_create :push_later, unless: :pushed?

  # == Scopes ==

  scope :to_friends, -> { where(recipient_type: "Friend") }
  scope :to_users, -> { where(recipient_type: "User") }
  scope :delivered, -> { where.not(delivered_at: nil) }
  scope :undelivered, -> { where(delivered_at: nil) }

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

  sig { returns(T.nilable(String)) }
  def delivery_token
    deprecated_delivery_token || generate_delivery_token
  end

  # == Methods ==

  sig { returns(NotificationMessage) }
  def message
    noticeable!.notification_message(recipient: recipient!)
  end
  delegate :title, :body, :image, to: :message

  sig { void }
  def push
    recipient = self.recipient
    PushRegistration.where(owner: recipient).find_each do |registration|
      registration.push(self)
    end
    deliver_to_native_devices(recipient) if recipient.is_a?(User)
    mark_as_pushed!
  end

  sig { void }
  def push_later
    job = PushNotificationJob
    if (wait = push_delay)
      job = job.set(wait:)
    end
    job.perform_later(self)
  end

  sig { void }
  def mark_as_pushed!
    update!(pushed_at: Time.current)
  end

  sig { void }
  def mark_as_delivered!
    update!(delivered_at: Time.current)
  end

  private

  # == Helpers ==

  sig { params(recipient: User).void }
  def deliver_to_native_devices(recipient)
    url_helpers = Rails.application.routes.url_helpers
    message = self.message
    apple_data = {
      aps: { "mutable-content" => 1 },
    }
    if (target_url = message.target_url)
      apple_data["target_url"] = target_url
    end
    sender = case (noticeable = self.noticeable)
    when Post
      noticeable.space || noticeable.world
    when PostReaction
      post = noticeable.post!
      post.space || post.world
    end
    if message.image
      apple_data["image_url"] =
        url_helpers.rails_representation_path(message.image, only_path: true)
    end
    if sender
      if (icon_blob = sender.icon_blob)
        icon_variant = icon_blob.variant(
          resize_to_fill: [ 192, 192 ],
          format: "png",
        )
        apple_data["icon_url"] =
          url_helpers.rails_representation_path(icon_variant, only_path: true)
      end
    end
    notification = NativeNotification
      .with_apple(apple_data)
      .new(
        thread_id: native_notification_thread_id,
        title: message.title,
        body: message.body,
        badge: recipient.notifications_received_since_last_cleared.count,
        # data: {
        #   notification_id: id,
        #   delivery_token: delivery_token,
        #   target_url: message.target_url,
        #   image_url: message.image&.src,
        # }.compact,
      )
    notification.deliver_later_to(recipient.native_devices)
  end

  sig { returns(T.nilable(String)) }
  def native_notification_thread_id
    noticeable = self.noticeable
    case noticeable
    when Friend
      noticeable.world_id
    when Post
      noticeable.space_id || noticeable.world_id
    end
  end

  # sig { returns(Hash) }
  # def native_notification_apple_data
  #   data = T.let({ aps: { "mutable-content" => 1 } }, Hash)
  #   case noticeable
  #   when Friend

  #   end
  #   end
  #   data
  # end
end
