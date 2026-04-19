# typed: true
# frozen_string_literal: true

class Components::WorldForm < Components::Base
  # == Configuration ==

  sig { params(world: World, options: T.untyped).void }
  def initialize(world:, **options)
    @world = world
    @options = options
    super()
  end

  # == Component ==

  sig { override.void }
  def view_template
    form_with(model: @world, class: "flex flex-col gap-y-4", **@options) do |form|
      form.field(:name) do |f|
        f.label { "name" }
        f.text_input
        f.error
      end
      form.field(:icon) do |f|
        f.label { "icon" }
        f.file_input(direct_upload: true)
        f.error
      end
      form.button do
        Icon("huge/plus-sign-square", class: "size-4", data: { icon: "inline-start" })
        span { "create world" }
      end
    end
  end
end
