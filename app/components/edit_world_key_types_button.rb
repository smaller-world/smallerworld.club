# typed: strict
# frozen_string_literal: true

class Components::EditWorldKeyTypesButton < Components::Base
  # == Initialization ==

  sig { params(world: World, attributes: T.untyped).void }
  def initialize(world:, **attributes)
    super(**attributes)
    @world = world
  end

  # == Component ==

  sig { override.void }
  def view_template
    Components::Dialog() do |dialog|
      dialog.with_trigger_button do |button|
        button.inline_start_icon("huge/settings-01")
        span { "edit key types" }
      end

      dialog.with_content do |dialog_content|
        dialog_content.header do |dialog_header|
          dialog_header.title do
            "edit key types"
          end
        end

        Components::ItemGroup() do |item_group|
          @world.key_types.alphabetical.each do |key_type|
            item_group.item(
              element: :a,
              href: url_for([ :edit, key_type ]),
              variant: :outline,
              size: :sm,
            ) do |item|
              item.media(variant: :icon) do
                Icon(
                  "huge/key-02",
                  class: "text-key-foreground",
                  data: {
                    key_color: key_type.color,
                  },
                )
              end
              item.content do |item_content|
                item_content.title do
                  key_type.name
                end
              end
            end
          end

          div

          item_group.item(
            element: :a,
            href: url_for([ :new, @world, :key_type ]),
            variant: :muted,
            size: :sm,
          ) do |item|
            item.media(variant: :icon) do
              Icon("huge/key-02")
            end
            item.content(class: "gap-0") do |item_content|
              item_content.title do
                "add a new key type"
              end
            end
          end
        end
      end
    end
  end
end
