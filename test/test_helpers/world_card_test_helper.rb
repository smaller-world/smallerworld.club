# typed: strict
# frozen_string_literal: true

# Dumb, composable builders for world-card records. No conditional logic —
# combine them to express scenarios. See docs/testing.md.
module WorldCardTestHelper
  extend T::Sig
  extend T::Helpers

  requires_ancestor { ActiveSupport::TestCase }

  # == Methods ==

  # Creates a world card registered to the shared passkit device fixture,
  # making it `active` (the `active` scope requires a pass registration).
  sig { params(world: World, granted_key_color: Symbol).returns(WorldCard) }
  def create_registered_card(world:, granted_key_color: :blue)
    card = world.cards.create!(granted_key_color:)
    card.pass!.registrations.create!(device: passkit_devices(:default))
    card
  end
end

ActiveSupport.on_load(:active_support_test_case) do
  include WorldCardTestHelper
end
