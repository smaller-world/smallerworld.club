# typed: strict
# frozen_string_literal: true

class Views::WorldKeys::Index < Views::Base
  # == Initialization ==

  sig { params(world: World).void }
  def initialize(world:)
    @world = world
    super()
  end

  # == View ==

  sig { override.void }
  def view_template
    Components::AppLayout(page_title: "your friends") do |layout|
      layout.page_container(class: "max-w-lg space-y-6") do
        div(class: "flex gap-6 justify-between", hidden: hotwire_native_app?) do
          button_back_to(@world.name, @world, variant: :secondary)
        end

        if @world.keys.any?
          div(class: "flex flex-col gap-4") do
            Components::ItemGroup(class: "gap-2") do
              @world.keys.each do |world_key|
                world_key_item(world_key)
              end
            end

            button_link_to(
              "give a key to a new friend",
              [ :new, @world, :key_grant ],
              variant: :default,
              size: :lg,
              icon: "huge/user-add-01",
              class: "self-center",
            )
          end
        else
          Components::Empty() do |empty|
            empty.header do
              empty.title do
                "nobody has access to your world!"
              end
              empty.description do
                "you haven't shared any world keys with anyone yet"
              end
            end
            empty.content do
              button_link_to(
                "invite a friend to your world",
                [ :new, @world, :key_grant ],
                variant: :default,
                icon: "huge/user-add-01",
              )
            end
          end

        end
      end
    end
  end

  private

  # == Helpers ==

  sig { params(world_key: WorldKey).void }
  def world_key_item(world_key)
    recipient = world_key.recipient!
    Components::Item(variant: :muted, class: "flex-nowrap items-start") do |item|
      item.content do
        item.title do
          recipient.name
        end
      end

      item.actions(class: "items-start gap-2") do
        div(class: "flex items-center justify-end gap-0 flex-wrap ") do
          world_key.granted_post_types.secret.each do |post_type|
            Components::Badge(
              variant: :ghost,
              class: "text-muted-foreground",
            ) do |badge|
              if (icon = post_type.icon)
                badge.inline_start_icon(icon)
              end
              span { post_type.label }
            end
          end
        end

        div(class: "flex items-center gap-1") do
          if @world.post_types.secret.any?
            button_link_to(
              "edit key",
              [ :edit, world_key ],
              variant: :secondary,
              size: :xs,
              icon: "huge/key-02",
            )
          end

          Components::DropdownMenu() do |menu|
            menu.with_trigger_button(
              variant: :ghost,
              size: :icon_xs,
              class: "text-muted-foreground",
            ) do
              Icon("huge/delete-01")
            end
            menu.with_content(
              anchor: [ :bottom, :end ],
              class: "min-w-auto",
            ) do |menu_content|
              form_with(url: world_key, method: :delete) do
                menu_content.button_item(type: :submit, variant: :destructive) do
                  Icon("huge/delete-01")
                  span { "destroy key" }
                end
              end
            end
          end
        end
      end
    end
  end
end
