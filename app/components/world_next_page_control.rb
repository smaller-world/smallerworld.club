# typed: strict
# frozen_string_literal: true

class Components::WorldNextPageControl < Components::Base
  # == Initialization ==

  sig { params(world: World, pagy: T.nilable(Pagy), attributes: T.untyped).void }
  def initialize(world:, pagy:, **attributes)
    super(**attributes)
    @world = world
    @pagy = pagy
  end

  # == Component ==

  sig { override.void }
  def view_template
    render Components::NextPageControl.new(
      target: [ @world, :posts ],
      pagy: @pagy,
      autoclick: true,
      **@attributes,
    ) do
      Icon("huge/loading-03", data: { icon: "inline-start" })
      span { "load more" }
    end
  end
end
