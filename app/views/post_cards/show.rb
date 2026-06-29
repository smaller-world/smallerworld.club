# typed: strict
# frozen_string_literal: true

class Views::PostCards::Show < Views::Base
  # == Initialization ==

  sig { params(post: Post, replied: T::Boolean).void }
  def initialize(post:, replied:)
    super()
    @post = post
    @replied = replied
  end

  # == View ==

  sig { override.void }
  def view_template
    Components::PostCard(post: @post, replied: @replied)
  end
end
