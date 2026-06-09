# typed: strict
# frozen_string_literal: true

class Components::AcceptWorldKeyGrantForm < Components::Base
  # == Initialization ==

  sig { params(world: World, grant: String, attributes: T.untyped).void }
  def initialize(world:, grant:, **attributes)
    super(**attributes)
    @world = world
    @grant = grant
  end

  # == Component ==

  sig { override.void }
  def view_template
    form_with(url: accept_world_key_grant_path(grant: @grant), **@attributes) do |form|
      submit_button_for(form, size: :lg) do
        Icon("huge/door-01")
        span { "enter #{@world.name}" }
      end
    end
  end
end
