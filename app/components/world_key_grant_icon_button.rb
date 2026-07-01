# typed: strict
# frozen_string_literal: true

class Components::WorldKeyGrantIconButton < Components::Base
  # == Initialization ==

  sig { params(world: World, attributes: T.untyped).void }
  def initialize(world:, **attributes)
    super(**attributes)
    @world = world
  end

  sig { override.returns(T.untyped) }
  def view_template
    Components::Button(
      element: :a,
      href: url_for([ :new, @world, :key_grant ]),
      variant: :secondary,
      size: :icon_sm,
      **mix(
        { class: "absolute -top-2 -right-2 border-primary/40" },
        @attributes,
      ),
    ) do
      Icon("huge/qr-code")
    end
  end
end
