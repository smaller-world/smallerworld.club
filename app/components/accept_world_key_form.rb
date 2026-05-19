# typed: true
# frozen_string_literal: true

class Components::AcceptWorldKeyForm < Components::Base
  # == Initialization ==

  sig { params(world_key: WorldKey, attributes: T.untyped).void }
  def initialize(world_key:, **attributes)
    @world_key = world_key
    @world = T.let(world_key.world!, World)
    super(**attributes)
  end

  # == Component ==

  sig { override.void }
  def view_template
    div(class: "flex flex-col gap-4 items-center") do
      Icon(
        "huge/key-02",
        class: "size-12",
        style: "color: var(--world-key-color-#{@world_key.color})",
      )

      form_with(model: [ :accept, @world_key ]) do |form|
        form.hidden_field(:grant, value: @world.key_grant(color: @world_key.color))
        submit_button_for(form, size: :lg) do
          Icon("huge/door-01")
          span { "enter #{@world.name}" }
        end
      end
    end
  end
end
