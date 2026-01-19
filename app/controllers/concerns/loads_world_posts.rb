# typed: true
# frozen_string_literal: true

module LoadsWorldPosts
  extend T::Sig
  extend T::Helpers
  extend ActiveSupport::Concern

  requires_ancestor { ApplicationController }

  # == Configuration ==

  POSTS_PER_PAGE = 5

  private

  # == Helpers ==

  sig { params(world: World).returns([ Pagy, T::Enumerable[Post] ]) }
  def paginated_world_posts(world)
    scope = world.posts
      .order(created_at: :desc, id: :asc)
      .with_attached_images
      .with_quoted_post_and_attached_images
      .with_rich_text_body_and_embeds
    if signed_in?
      paginate_world_posts(authorized_scope(scope))
    elsif (friend = current_friend)
      paginate_world_posts(scope.visible_to(friend))
    else
      pagy, posts = paginate_world_posts(scope.visible_to_friends)
      masked_posts = posts.map do |post|
        post.visibility == :public ? post : post.becomes(MaskedPost)
      end
      [ pagy, masked_posts ]
    end
  end

  sig do
    params(scope: ActiveRecord::Relation)
      .returns([ Pagy, T::Enumerable[Post] ])
  end
  def paginate_world_posts(scope)
    pagy(
      :keyset,
      scope,
      limit: POSTS_PER_PAGE,
    )
  end
end
