# typed: strict
# frozen_string_literal: true

class Components::WorldKeysForm < Components::Base
  # == Initialization ==

  sig { params(world: World, attributes: T.untyped).void }
  def initialize(world:, **attributes)
    super(**attributes)
    @world = world
  end

  # == Component ==

  sig { override.void }
  def view_template
    form_with(model: @world, **mix(
      {
        class: "flex flex-col gap-4",
        data: {
          controller: "world-form haptic-bridge",
          action: "turbo:submit-end->haptic-bridge#vibrate",
        },
      },
      @attributes,
    )) do |form|
      Components::FieldSet(class: "gap-4") do |set|
        div do
          set.legend(class: "mb-0") do
            "key labels"
          end
          set.description do
            "help yourself remember what your key colors represent!"
          end
        end
        set.group(class: "md:grid md:grid-cols-2 gap-2") do
          WorldKey.color.values.each do |value|
            field_for(form, :"#{value}_key_label") do |field|
              field.input_group do |group|
                group.addon do
                  Icon("huge/key-02", style: "color: var(--world-key-color-#{value})")
                end
                group.text_input(
                  placeholder: value.humanize(capitalize: false),
                  class: "text-end",
                )
                group.addon(align: :inline_end) do |addon|
                  addon.text { "key" }
                end
              end
              field.error
            end
          end
        end
      end

      submit_button_for(form, size: :lg) do |button|
        if @world.new_record?
          button.inline_start_icon("huge/plus-sign-square")
          span(data: { world_form_target: "submitButtonLabel" }) do
            "create world"
          end
        else
          button.inline_start_icon("huge/floppy-disk")
          span { "save changes" }
        end
      end
    end
  end
end
