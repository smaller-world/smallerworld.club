# typed: strict
# frozen_string_literal: true

class Views::Reactions::Index < Views::Base
  # == Initialization ==

  sig { params(post: Post, new_reaction: Reaction).void }
  def initialize(post:, new_reaction: post.reactions.build)
    @post = post
    @new_reaction = new_reaction
    super()
  end

  # == View ==

  sig { override.void }
  def view_template
    Components::PostReactions(post: @post, new_reaction: @new_reaction)
  end
end
