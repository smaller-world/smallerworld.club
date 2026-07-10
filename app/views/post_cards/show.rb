# typed: strict
# frozen_string_literal: true

class Views::PostCards::Show < Views::Base
  # == Initialization ==

  sig { params(current_user: User, post: Post, replied: T::Boolean).void }
  def initialize(current_user:, post:, replied:)
    super()
    @current_user = current_user
    @post = post
    @replied = replied
  end

  # == View ==

  sig { override.void }
  def view_template
    Components::PostCard(current_user: @current_user, post: @post, replied: @replied)
  end
end
