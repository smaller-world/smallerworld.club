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
    form_with(
      model: @world,
      url: [ @world, :keys ],
      **normalize_mix(
        {
          class: "flex flex-col gap-4",
          data: {
            controller: "haptic-bridge",
            action: "turbo:submit-end->haptic-bridge#vibrate",
          },
        },
        @attributes,
      ),
    ) do |form|
      Components::FieldSet(class: "gap-4") do |set|
        div do
          set.legend(class: "mb-0") do
            "custom key names"
          end
          set.description do
            "set custom names for your keys. only you see these names."
          end
        end
        set.group(class: "min-[500px]:grid min-[500px]:grid-cols-2 gap-2") do
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
