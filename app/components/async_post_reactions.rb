# typed: strict
# frozen_string_literal: true

class Components::AsyncPostReactions < Components::Base
  # == Initialization ==

  sig { params(post: Post, attributes: T.untyped).void }
  def initialize(
    post:,
    **attributes
  )
    super(**attributes)
    @post = post
  end

  # == Component ==

  sig { override.void }
  def view_template
    turbo_frame_tag(
      dom_id(@post, :reactions),
      src: [ @post, :reactions ],
      loading: :lazy,
      **mix(
        {
          class: "post-reactions",
          data: {
            controller: "frame-reload",
          },
        },
        @attributes,
      ),
    ) do
      # Placeholder
      Components::Button(
        element: :div,
        variant: :ghost,
        size: :icon,
        class: "rounded-full skeleton",
      ) do
        span(class: "font-emoji text-lg") do
          "🤣"
        end
      end
    end
  end
end
