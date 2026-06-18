# typed: strict
# frozen_string_literal: true

module Reaction::Notifications
  extend T::Sig
  extend T::Helpers
  extend ActiveSupport::Concern

  abstract!
  requires_ancestor { Reaction }

  include Phlex::Rails::Helpers::DOMID
  include Noticeable

  # == Configuration ==

  NOTIFICATION_DELIVERY_DELAY = T.let(1.minute, ActiveSupport::Duration)

  # == Hooks ==

  included do
    T.bind(self, T.class_of(Reaction))

    after_create_commit :create_notification_for_world_owner!,
      unless: :reactor_has_other_post_reactions?
  end

  # == Methods ==

  sig { override.params(recipient: User).returns(Notification::Message) }
  def notification_message(recipient:)
    post = post!
    world = post.world!
    reactor = reactor!
    Notification::Message.new(
      target_url: [ world, anchor: dom_id(post) ],
      title: "#{emoji} from #{reactor.name}",
      body: "> #{post.card_snippet}",
      world:,
    )
  end

  private

  # == Helpers ==

  sig { returns(T::Boolean) }
  def reactor_has_other_post_reactions?
    Reaction.where.not(id:).exists?(post_id:, reactor_id:)
  end

  # == Callbacks ==

  sig { void }
  def create_notification_for_world_owner!
    notifications.create!(recipient: world_owner!)
  end
end
