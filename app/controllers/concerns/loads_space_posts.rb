# typed: true
# frozen_string_literal: true

module LoadsSpacePosts
  extend T::Sig
  extend T::Helpers
  extend ActiveSupport::Concern

  requires_ancestor { ApplicationController }

  # == Configuration ==

  POSTS_PER_PAGE = 5

  private

  # == Helpers ==

  sig { params(space: Space).returns([ Pagy, T::Enumerable[Post] ]) }
  def paginated_space_posts(space)
    scope = authorized_scope(space.posts)
      .order(created_at: :desc, id: :asc)
      .with_author_world
      .with_attached_images
      .with_quoted_post_and_attached_images
      .with_rich_text_body_and_embeds
    pagy(:keyset, scope, limit: POSTS_PER_PAGE)
  end
end
