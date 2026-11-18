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
    Components::NextPageControl(**T.unsafe({
      target: [ @world, :posts ],
      pagy: @pagy,
      autoclick: true,
      **@attributes,
    })) do |control|
      if @post_type
        control.with_param(name: "type_id", value: @post_type.id)
      end
      control.with_submit do |button|
        button.inline_start_icon("huge/loading-03")
        span { "load more" }
      end
    end
  end
end
