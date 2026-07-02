# typed: strict
# frozen_string_literal: true

class Views::WorldKeys::Edit < Views::Base
  # == Initialization ==

  sig { params(world_key: WorldKey).void }
  def initialize(world_key:)
    super()
    @world_key = world_key
    @world = T.let(@world_key.world!, World)
    @recipient = T.let(@world_key.recipient!, User)
  end

  # == View ==

  sig { override.void }
  def view_template
    Components::AppLayout(
      page_title: "edit #{@recipient.name}'s key",
    ) do |layout|
      layout.page_container(class: "max-w-lg space-y-6") do
        unless hotwire_native_app?
          button_back_to("your friends", [ @world, :keys ], variant: :secondary)
        end

        Components::Item(
          variant: :muted,
          size: :xs,
          class: "gap-3 pr-3.5",
        ) do |item|
          item.media do
            div(class: "relative") do
              image_tag(
                @world.page_icon_variant,
                class: "world-icon",
                data: { world_icon_size: "xs" },
              )
              div(class: "absolute inset-0 flex items-center justify-center") do
                Icon("huge/key-01", class: "size-6 text-white")
              end
            end
          end
          item.content do
            item.title do
              "#{@recipient.name}'s key"
            end
            item.description(class: "text-xs") do
              plain("you gave #{@recipient.name} a key to your world on ")
              local_time(@world.created_at)
            end
          end
        end

        div(class: "flex flex-col gap-0.5") do
          Components::WorldKeyForm(world_key: @world_key)
          Components::DropdownMenu() do |menu|
            menu.with_trigger_button(
              variant: :link,
              size: :sm,
              class: "text-muted-foreground",
            ) do
              "destroy key"
            end
            menu.with_content(anchor: :bottom) do |menu_content|
              menu_content.label(class: "pt-1.5 pb-0 text-center") do
                "are you sure?"
              end
              form_with(url: @world_key, method: :delete) do
                menu_content.button_item(
                  type: :submit,
                  variant: :destructive,
                  class: "justify-center",
                  data: {
                    action: "dropdown-menu#preventAutoClose",
                  },
                ) do
                  Icon("huge/delete-01")
                  span { "really destroy" }
                  div(class: "w-1")
                end
              end
            end
          end
        end
      end
    end
  end
end
