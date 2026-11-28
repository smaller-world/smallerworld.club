# typed: strict
# frozen_string_literal: true

class Views::WorldKeyTypes::Index < Views::Base
  include Phlex::Rails::Helpers::Pluralize

  # == Initialization ==

  sig { params(world: World).void }
  def initialize(world:)
    super()
    @world = world
  end

  # == View ==

  sig { override.void }
  def view_template
    Components::AppLayout(page_title: "your key types") do |app_layout|
      app_layout.with_navigation(class: "max-w-md") do
        button_back_to("your friends", [ @world, :keys ], variant: :secondary)
      end

      app_layout.page_container(class: "max-w-md") do
        Components::ItemGroup() do |item_group|
          if @world.key_types.any?
            @world.key_types.alphabetical.each do |key_type|
              key_type_item(key_type)
            end

            item_group.item(class: "flex gap-3") do
              item_group.separator(class: "flex-1 shrink-auto")
              p(class: "text-center text-xs text-muted-foreground") do
                "pick a key to edit, or"
              end
              item_group.separator(class: "flex-1 shrink-auto")
            end
          end

          item_group.item(
            element: :a,
            href: new_world_key_type_path(@world),
            variant: :muted,
            size: :sm,
          ) do |item|
            item.media(variant: :icon) do
              Icon("huge/plus-sign-square")
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

  private

  # == Helpers ==

  sig { params(key_type: WorldKeyType).void }
  def key_type_item(key_type)
    num_keys = num_keys_with_type(key_type)
    Components::Item(
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
        if num_keys.positive?
          item_content.description do
            plain(pluralize(key_count_by_type_id.fetch(key_type.id, 0), "friend"))
            whitespace
            plain("with this key type")
          end
        end
      end
    end
  end

  sig { returns(T::Hash[String, Integer]) }
  def key_count_by_type_id
    @key_count_by_type_id ||= T.let(
      @world.keys.group(:type_id).count,
      T.nilable(T::Hash[String, Integer]),
    )
  end

  sig { params(key_type: WorldKeyType).returns(Integer) }
  def num_keys_with_type(key_type)
    key_count_by_type_id.fetch(key_type.id, 0)
  end
end
