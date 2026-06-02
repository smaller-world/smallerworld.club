# typed: strict
# frozen_string_literal: true

class Components::AcceptWorldKeyForm < Components::Base
  # == Initialization ==

  sig { params(key: WorldKey, attributes: T.untyped).void }
  def initialize(key:, **attributes)
    super(**attributes)
    @key = key
    @world = T.let(key.world!, World)
  end

  # == Component ==

  sig { override.void }
  def view_template
    form_with(model: [ :accept, @key ], **@attributes) do |form|
      form.hidden_field(:grant, value: @world.key_grant(color: @key.color))
      submit_button_for(form, size: :lg) do
        Icon("huge/door-01")
        span { "enter #{@world.name}" }
      end
    end
  end
end
