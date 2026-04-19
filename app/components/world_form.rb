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
    component_form_with(
      model: @world,
      class: "flex flex-col gap-y-4",
      **@options,
    ) do |form|
      form.field(:name) do |f|
        f.label { "name" }
        f.text_input
        f.error
      end
      form.field(:icon) do |f|
        f.label { "icon" }
        f.clearable_file_input(direct_upload: true)
        f.error
      end
      form.button do |button|
        if @world.new_record?
          button.icon("huge/plus-sign-square", align: "inline-start")
          span { "create world" }
        else
          button.icon("huge/floppy-disk", align: "inline-start")
          span { "save changes" }
        end
      end
    end
  end
end
