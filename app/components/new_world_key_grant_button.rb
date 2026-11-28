# typed: strict
# frozen_string_literal: true

class Components::NewWorldKeyGrantButton < Components::Base
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
        { class: "new-world-key-grant-button" },
        @attributes,
      ),
    ) do
      Icon("huge/user-add-01")
    end
  end
end
