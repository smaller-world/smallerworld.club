# typed: true
# frozen_string_literal: true

class Views::Home::Show < Views::Base
  include Phlex::Rails::Helpers::ButtonTo

  # == Initialization ==

  sig { params(current_user: User).void }
  def initialize(current_user:)
    @current_user = current_user
    super()
  end

  # == View ==

  sig { override.void }
  def view_template
    user = Current.user
    Components::Layout(page_title: "home") do |layout|
      layout.page_container(class: "max-w-lg space-y-6") do
        Components::Card() do |card|
          card.content(class: "flex items-center gap-x-4") do
            div(class: "flex-1 flex items-center gap-x-4") do
              # if (blob = user.oauth_picture_blob)
              #   image_tag(blob, class: "size-16 rounded-full")
              # end
              div(class: "flex flex-col gap-y-1") do
                span(class: "font-semibold text-lg") do
                  "hi, #{user.name}"
                end
                code(class: "text-xs text-muted-foreground") do
                  user.parsed_phone_number.to_s
                end
              end
            end
            button_to(
              session_path,
              method: :delete,
              **Components::Button.root_attributes(variant: :destructive),
            ) do
              Icon(
                "huge/logout-01",
                class: "size-4",
                data: { icon: "inline-start" },
              )
              span { "sign out" }
            end
          end
          card.footer do
            span do
              plain("your time zone is: ")
              code(class: "text-sm") { user.time_zone.name }
            end
          end
        end

        if (world = @current_user.own_world)
          button_link_to(
            "go to your world",
            world_path(world),
            variant: :default,
            icon: "huge/earth",
          )
        else
          button_link_to(
            "create your world",
            new_world_path,
            variant: :default,
            icon: "huge/earth",
          )
        end

        if (worlds = @current_user.accessible_worlds.presence)
          div(class: "flex flex-col gap-2") do
            h2 { "worlds you can visit:" }
            Components::ItemGroup() do
              worlds.find_each do |world|
                Components::Item(
                  element: :a,
                  href: url_for(world),
                  variant: :muted,
                ) do |item|
                  item.media do
                    image_tag(
                      world.page_icon_variant,
                      class: "size-16 rounded-world-icon",
                    )
                  end
                  item.content(class: "gap-0") do
                    item.title do
                      world.name
                    end
                    item.description do
                      world.friendly_id
                    end
                  end
                end
              end
            end
          end
        end

        # Components::Dialog() do |dialog|
        #   dialog.with_content do |content|
        #     content.header do |header|
        #       header.title { "Hello from Dialog" }
        #       header.description do
        #         "This is a test dialog using Tailwind Elements + shadcn styling."
        #       end
        #     end

        #     p do
        #       "It works! Close me with the X button, the Cancel button, or " \
        #         "press Escape."
        #     end

        #     content.footer(show_close_button: true) do
        #       "i'm a foot. (what are you?)"
        #     end
        #   end

        #   dialog.with_trigger_button(class: "block") do
        #     "open dialog"
        #   end
        # end

        # div(class: "flex flex-col gap-y-4") do
        #   div do
        #     h2(class: "text-2xl") { "your worlds" }
        #     ul(class: "list-inside list-disc") do
        #       @current_user.worlds.each do |world|
        #         li do
        #           button_link_to(world.name, world, class: "h-6")
        #         end
        #       end
        #     end
        #   end

        # end
      end
    end
  end
end
