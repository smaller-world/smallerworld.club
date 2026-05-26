# typed: strict
# frozen_string_literal: true

class Views::WorldKeys::Index < Views::Base
  # == Initialization ==

  sig { params(world: World, keys_by_recipient: T::Hash[User, T::Array[WorldKey]]).void }
  def initialize(world:, keys_by_recipient:)
    @world = world
    @keys_by_recipient = keys_by_recipient
    super()
  end

  # == View ==

  sig { override.void }
  def view_template
    Components::Layout(page_title: "share world key") do |layout|
      layout.page_container(class: "max-w-lg space-y-4") do
        button_back_to(@world.name, @world)

        Components::Card(class: "overflow-visible") do |card|
          card.header(class: "text-center") do
            card.title(element: :h1, class: "text-xl") do
              "friends who have access to your world"
            end
            # card.description do
            #   "> hint: when you write posts, you can select which colors can see your post"
            # end
          end
          card.content do
            if (keys_by_recipient = @keys_by_recipient.presence)
              Components::ItemGroup(class: "gap-2") do
                keys_by_recipient.each_pair do |recipient, keys|
                  item(recipient:, keys:)
                end
              end
            else
              Components::Empty(class: "gap-2") do |empty|
                empty.header(class: "gap-0.5") do
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
                    variant: :secondary,
                    icon: "huge/user-add-01",
                  )
                end
              end
            end
          end

          if @keys_by_recipient.present?
            card.footer(class: "flex flex-col items-center") do
              button_link_to(
                "invite another friend",
                [ :new, @world, :key_grant ],
                variant: :secondary,
                size: :sm,
                icon: "huge/user-add-01",
                class: "self-center text-xs",
              )
            end
          end
        end
      end
    end
  end

  private

  # == Helpers ==

  sig { params(recipient: User, keys: T::Array[WorldKey]).void }
  def item(recipient:, keys:)
    Components::Item(variant: :outline) do |item|
      item.content do
        item.title do
          recipient.name
        end
      end
      item.actions do
        keys.each do |key|
          Components::DropdownMenu() do |menu|
            menu.with_trigger_badge(variant: :outline, class: "h-6 [&>svg]:size-4") do
              Icon("huge/key-02", style: "color: var(--world-key-color-#{key.color})")
            end
            menu.with_content(anchor: [ :bottom, :end ]) do |content|
              form_with(url: key, method: :delete) do
                content.button_item(type: :submit, variant: :destructive) do
                  Icon("huge/delete-01")
                  span { "revoke key" }
                end
              end
            end
          end
        end
      end
    end
  end
end
