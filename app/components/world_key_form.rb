# typed: strict
# frozen_string_literal: true

class Components::WorldKeyForm < Components::Base
  # == Initialization ==

  sig do
    params(
      world_key: WorldKey,
      attributes: T.untyped,
    ).void
  end
  def initialize(world_key:, **attributes)
    super(**attributes)
    @world_key = world_key
  end

  # == Component ==

  sig { override.void }
  def view_template
    Components::Form(@world_key, **mix({ class: "world-key-form" }, @attributes)) do |form|
      Components::FieldSet() do |field_set|
        field_set.legend(variant: :label, class: "mb-0") do
          "key type"
        end
        form.Field(:type_id).radios(@world_key.world_key_types.alphabetical) do |choice|
          div(class: "flex items-center gap-1") do
            choice.label(
              class: "cursor-pointer has-data-checked:border-key-foreground",
              data: {
                key_color: choice.item.color,
              },
            ) do
              Components::Field(orientation: :horizontal, invalid: form.invalid?(:type)) do |field|
                Icon("huge/key-02", class: "size-4 text-key-foreground")
                field.content do
                  field.title(class: "text-xs text-key-foreground text-center text-balance") do
                    choice.item.name
                  end
                end
                choice.input(invalid: form.invalid?(:type), data: { action: "submit#request" })
              end
            end
            button_link_to(
              "edit",
              [ :edit, choice.item ],
              size: :sm,
              class: "text-muted-foreground",
              data: {
                controller: "return-to-self",
              },
            )
          end
        end
        form.error_for(:type)
      end

      form.submit do |button|
        button.inline_start_icon("huge/floppy-disk")
        span { "save changes" }
      end
    end
  end
end
