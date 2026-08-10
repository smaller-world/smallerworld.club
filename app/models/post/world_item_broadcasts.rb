# typed: strict
# frozen_string_literal: true

module Post::WorldItemBroadcasts
  extend T::Sig
  extend T::Helpers
  extend ActiveSupport::Concern
  include ActionView::RecordIdentifier

  requires_ancestor { Post }

  class_methods do
    extend T::Sig
    extend T::Helpers

    requires_ancestor { T.class_of(Post) }

    # == Macros ==

    sig { void }
    def broadcasts_world_items
      after_update_commit(:broadcast_world_item_update, if: :world_item_previously_changed?)
      after_destroy_commit(:broadcast_world_item_removal)
      after_create_commit(:broadcast_world_item_prepend)
    end
  end

  private

  # == Helpers ==

  sig { returns(T::Boolean) }
  def world_item_previously_changed?
    emoji_previously_changed? ||
      title_previously_changed? ||
      hidden_from_ids_previously_changed? ||
      ordered_images_attachment_ids_previously_changed? ||
      plain_body_previously_changed? ||
      type_id_previously_changed?
  end

  # == Callbacks ==

  sig { void }
  def broadcast_world_item_prepend
    world = world!
    broadcast_prepend_to(
      world,
      :posts,
      target: :post_items,
      renderable: Components::AsyncWorldPostItem.new(post: self, newly_created: true),
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
