# typed: strict
# frozen_string_literal: true

class Components::AsyncWorldPostItem < Components::Base
  # == Initialization ==

  sig { params(post: Post, initially_hidden: T::Boolean, attributes: T.untyped).void }
  def initialize(post:, initially_hidden: false, **attributes)
    super(**attributes)
    @post = post
    @initially_hidden = initially_hidden
  end

  # == Component ==

  sig { override.void }
  def view_template
    li(id: dom_id(@post, :item), **mix(
      {
        hidden: @initially_hidden,
        data: {
          controller: "async-item",
        },
      },
      @attributes,
    )) do
      turbo_frame_tag(
        @post,
        :card,
        src: [ @post, :card ],
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
