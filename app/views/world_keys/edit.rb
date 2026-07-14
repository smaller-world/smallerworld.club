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
    ) do |app_layout|
      app_layout.page_container(class: "max-w-lg space-y-6") do
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
          item.content do |item_content|
            item_content.title do
              "#{@recipient.name}'s key"
            end
            item_content.description(class: "text-xs") do
              plain("you gave #{@recipient.name} a key to your world on ")
              local_time(@world.created_at)
            end
          end
        end

        div(class: "flex flex-col gap-0.5") do
          Components::WorldKeyForm(world_key: @world_key)
          Components::ConfirmDeleteButton(
            url: @world_key,
            variant: :link,
            confirm_label: "really destroy",
            class: "self-center text-muted-foreground",
          ) do
            "destroy key"
          end
        end
      end
    end
  end
end
