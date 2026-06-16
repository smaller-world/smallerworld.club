# typed: strict
# frozen_string_literal: true

class Components::WorldPostItems < Components::Base
  # == Initialization ==

  sig { params(posts: T::Enumerable[Post], replied_post_ids: T::Set[String]).void }
  def initialize(posts:, replied_post_ids:)
    super()
    @posts = posts
    @replied_post_ids = replied_post_ids
  end

  # == Component ==

  sig { override.void }
  def view_template
    @posts.each do |post|
      li do
        Components::PostCard(
          post:,
          replied_post_ids: @replied_post_ids,
        )
      end
    end
  end
end
