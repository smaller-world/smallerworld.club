# typed: strict
# frozen_string_literal: true

class Components::WorldNextPageControl < Components::Base
  # == Initialization ==

  sig do
    params(
      world: World,
      post_type: T.nilable(PostType),
      pagy: T.nilable(Pagy),
      attributes: T.untyped,
    ).void
  end
  def initialize(world:, post_type:, pagy:, **attributes)
    super(**attributes)
    @world = world
    @post_type = post_type
    @pagy = pagy
  end

  # == Component ==

  sig { override.void }
  def view_template
    render Components::NextPageControl.new(
      target: [ @world, :posts ],
      pagy: @pagy,
      autoclick: true,
      **mix(
        {
          params: {
            type_id: @post_type&.id,
          }.compact,
        },
        @attributes,
      ),
    ) do
      Icon("huge/loading-03", data: { icon: "inline-start" })
      span { "load more" }
    end
  end
end
