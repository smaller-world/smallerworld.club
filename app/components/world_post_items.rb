# typed: strict
# frozen_string_literal: true

class Components::WorldPostItems < Components::Base
  # == Initialization ==

  sig do
    params(
      current_user: User,
      posts: T::Enumerable[Post],
      replied_post_ids: T.nilable(T::Set[String]),
      active_reports_by_post_id: T.nilable(T::Hash[String, Report]),
    ).void
  end
  def initialize(current_user:, posts:, replied_post_ids:, active_reports_by_post_id:)
    super()
    @current_user = current_user
    @posts = posts
    @replied_post_ids = replied_post_ids
    @active_reports_by_post_id = active_reports_by_post_id
  end

  # == Component ==

  sig { override.void }
  def view_template
    @posts.each do |post|
      li(id: dom_id(post, :item)) do
        active_report = if @active_reports_by_post_id
          @active_reports_by_post_id[post.id]
        end
        Components::PostCard(
          current_user: @current_user,
          post:,
          active_report:,
          replied: @replied_post_ids&.include?(post.id) || false,
          async_reactions: true,
        )
      end
    end
  end
end
