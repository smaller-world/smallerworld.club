# typed: true
# frozen_string_literal: true

module PostReactionsHelper
  extend T::Sig
  extend T::Helpers

  requires_ancestor { ActionView::Base }

  # == Methods ==

  sig { params(post: Post).returns(T::Array[PostReactionGroup]) }
  def post_reaction_groups(post)
    viewer = current_friend || current_user
    viewer_type = viewer&.class&.name
    viewer_id = viewer&.id
    post.reactions
      .group(:emoji)
      .select(
        :emoji,
        "COUNT(*) AS count",
        PostReaction.sanitize_sql_array([
          <<~SQL,
            BOOL_OR(
              CASE
                WHEN reactor_type = ? AND reactor_id = ? THEN TRUE
                ELSE FALSE
              END
            ) AS reacted
          SQL
          viewer_type,
          viewer_id,
        ]),
      ).map do |reaction|
      PostReactionGroup.new(
        emoji: reaction.emoji,
        count: reaction[:count],
        reacted: reaction[:reacted] || false,
      )
    end
  end
end
