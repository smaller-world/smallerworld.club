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
    subquery = post.reactions
      .group(:emoji)
      .select(
        :emoji,
        "COUNT(*) AS count",
        PostReaction.sanitize_sql_array([
          <<~SQL,
            ANY_VALUE(id) FILTER (
              WHERE reactor_type = ? AND reactor_id = ?
            ) AS current_reaction_id
          SQL
          viewer_type,
          viewer_id,
        ]),
      )
    PostReaction.from(subquery, :reactions)
      .select("*")
      .order(Arel.sql("current_reaction_id IS NOT NULL DESC"), "emoji ASC")
      .map do |reaction|
      PostReactionGroup.new(
        post:,
        emoji: reaction.emoji,
        count: reaction[:count],
        current_reaction_id: reaction[:current_reaction_id],
      )
    end
  end

  sig do
    params(
      group: PostReactionGroup,
      html_options: T.untyped,
      block: T.untyped,
    ).returns(String)
  end
  def post_reaction_group_button(group, **html_options, &block)
    action = if (reaction_id = group.current_reaction_id)
      html_options[:method] = :delete
      post_reaction_path(reaction_id)
    else
      params = html_options[:params] || {}
      params[:post_reaction] = { emoji: group.emoji }
      html_options[:params] = params
      post_reactions_path(group.post)
    end
    button_to(action, **html_options, &block)
  end
end
