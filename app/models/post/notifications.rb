# typed: strict
# frozen_string_literal: true

module Post::Notifications
  extend T::Sig
  extend T::Helpers
  extend ActiveSupport::Concern
  include ActionView::RecordIdentifier
  include Noticeable

  requires_ancestor { Post }

  # == Configuration ==

  NOTIFICATION_DELIVERY_DELAY = T.let(1.minute, ActiveSupport::Duration)

  # == Hooks ==

  included do
    T.bind(self, T.class_of(Post))

    after_create_commit :create_notifications_for_world_key_recipients!
  end

  # == Methods ==

  sig { override.params(recipient: User).returns(Notification::Message) }
  def notification_message(recipient:)
    world = world!
    Notification::Message.new(
      target_url: [ world, anchor: dom_id(self) ],
      title: world.name,
      body: snippet,
      world:,
    )
  end

  private

  # == Callbacks ==

  sig { void }
  def create_notifications_for_world_key_recipients!
    keys = world!.keys.accepted
    if (colors = key_colors)
      keys = keys.where(color: colors)
    end
    keys.find_each do |key|
      notifications.create!(
        recipient: key.recipient!,
        delivery_delay: NOTIFICATION_DELIVERY_DELAY,
      )
    end
  end
end
