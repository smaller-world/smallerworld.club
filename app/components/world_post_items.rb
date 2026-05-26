# typed: strict
# frozen_string_literal: true

class Components::WorldPostItems < Components::Base
  # == Initialization ==

  sig { params(posts: T::Enumerable[Post]).void }
  def initialize(posts:)
    super()
    @posts = posts
  end

  # == Component ==
  #
  sig { override.void }
  def view_template
    @posts.each do |post|
      li do
        Components::PostCard(post:)
      end
    end
  end
end
