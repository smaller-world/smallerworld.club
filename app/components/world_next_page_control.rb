# typed: true
# frozen_string_literal: true

class Components::WorldNextPageControl < Components::Base
  # == Initialization ==

  sig { params(world: World, pagy: T.nilable(Pagy), options: T.untyped).void }
  def initialize(world:, pagy:, **options)
    @world = world
    @pagy = pagy
    @options = options
    super()
  end

  # == Component ==

  sig { override.void }
  def view_template
    render Components::NextPageControl.new(
      target: [ @world, :posts ],
      pagy: @pagy,
      autoclick: true,
      **@options,
    ) do
      Icon("huge/loading-03", data: { icon: "inline-start" })
      span { "load more" }
    end
  end
end
