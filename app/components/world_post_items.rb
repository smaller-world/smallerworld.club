# typed: strict
# frozen_string_literal: true

class Components::WorldPostItems < Components::Base
  # == Initialization ==

  sig do
    params(
      posts: T::Enumerable[Post],
      replied_post_ids: T.nilable(T::Set[String]),
      created_post_id: T.nilable(String),
    ).void
  end
  def initialize(posts:, replied_post_ids:, created_post_id: nil)
    super()
    @posts = posts
    @replied_post_ids = replied_post_ids
    @created_post_id = created_post_id
  end

  # == Component ==

  sig { override.void }
  def view_template
    @posts.each do |post|
      li(id: dom_id(post, :item)) do
        Components::PostCard(
          post:,
          replied: @replied_post_ids&.include?(post.id) || false,
          async_reactions: true,
          show_notification_prompt: post.id == @created_post_id,
        )
      end
    end
  end
end
