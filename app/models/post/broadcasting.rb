# typed: strict
# frozen_string_literal: true

module Post::Broadcasting
  extend T::Sig
  extend T::Helpers
  extend ActiveSupport::Concern

  abstract!
  requires_ancestor { Post }

  include ActionView::RecordIdentifier

  # == Hooks ==

  included do
    T.bind(self, T.class_of(Post))

    after_update_commit :broadcast_world_item_update
    after_destroy_commit :broadcast_world_item_removal
    after_create_commit :broadcast_world_item_prepend
  end

  private

  # == Callbacks ==

  sig { void }
  def broadcast_world_item_prepend
    world = world!
    broadcast_prepend_to(
      world,
      :posts,
      target: :post_items,
      renderable: Components::AsyncWorldPostItem.new(post: self, initially_hidden: true),
    )
  end

  sig { void }
  def broadcast_world_item_update
    broadcast_replace_to(
      self,
      target: dom_id(self, :item),
      renderable: Components::AsyncWorldPostItem.new(post: self),
    )
  end

  sig { void }
  def broadcast_world_item_removal
    broadcast_remove_to(self, target: dom_id(self, :item))
  end
end
