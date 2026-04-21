# typed: true
# frozen_string_literal: true

class Components::WorldForm < Components::Base
  # == Initialization ==

  sig { params(world: World, options: T.untyped).void }
  def initialize(world:, **options)
    @world = world
    @options = T.let(options, T::Hash[Symbol, T.untyped])
    super()
  end

  # == Component ==

  sig { override.void }
  def view_template
    component_form_with(
      model: @world,
      class: "flex flex-col gap-y-4",
      **@options,
    ) do |form|
      form.field(:name) do |f|
        f.label { "name" }
        f.text_input(required: true)
        f.error
      end
      form.field(:icon) do |f|
        f.label { "icon" }
        f.clearable_file_input(direct_upload: true, required: true)
        f.error
      end
      form.button do |button|
        if @world.new_record?
          button.inline_start_icon("huge/plus-sign-square")
          span { "create world" }
        else
          button.inline_start_icon("huge/floppy-disk")
          span { "save changes" }
        end
      end
    end
  end
end
