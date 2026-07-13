# typed: strict
# frozen_string_literal: true

class Components::AsyncWorldPostItem < Components::Base
  # == Initialization ==

  sig { params(post: Post, newly_created: T::Boolean, attributes: T.untyped).void }
  def initialize(post:, newly_created: false, **attributes)
    super(**attributes)
    @post = post
    @newly_created = newly_created
  end

  # == Component ==

  sig { override.void }
  def view_template
    li(id: dom_id(@post, :item), **mix(
      {
        hidden: @newly_created,
        data: {
          controller: "async-item",
        },
      },
      @attributes,
    )) do
      turbo_frame_tag(
        @post,
        :card,
        target: "_top",
        src: [ @post, :card, newly_created: (true if @newly_created) ],
        data: {
          action: token_list(
            "turbo:frame-load->async-item#show",
            "turbo:before-fetch-response->async-item#removeWhenUnauthorized",
          ),
        },
      ) do
        Components::PostCardSkeleton()
      end
    end
  end
end
