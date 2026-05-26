# typed: strict
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
    Components::Layout(page_title: "home") do |layout|
      layout.page_container(class: "max-w-lg flex flex-col gap-8") do
        link_to(
          @current_user.own_world || new_world_path,
          class: "flex flex-col items-center gap-2 hover:underline",
        ) do
          icon_class = "size-32 rounded-world-icon shadow-md"
          if (world = @current_user.own_world)
            image_tag(world.page_icon_variant, class: icon_class)
          else
            Components::Button(
              element: :div,
              variant: :outline,
              class: icon_class,
            ) do
              Icon("huge/plus-sign-square", class: "size-7")
            end
          end
          span(class: "font-semibold font-heading") do
            @current_user.own_world&.name || "create your world"
          end
        end
        if (worlds = @current_user.accessible_worlds.presence)
          Components::Separator()
          div(class: "flex gap-4 flex-wrap justify-center") do
            worlds.each do |world|
              link_to(
                world,
                class: "flex flex-col items-center gap-2 hover:underline",
              ) do
                image_tag(
                  world.page_icon_variant,
                  class: "size-20 shadow-md rounded-world-icon",
                )
                span(class: "text-xs font-semibold font-heading") { world.name }
              end
            end
          end
          # div(class: "flex flex-col gap-2") do
          #   h2 { "worlds you can visit:" }
          #   Components::ItemGroup() do
          #     worlds.find_each do |world|
          #       Components::Item(
          #         element: :a,
          #         href: url_for(world),
          #         variant: :muted,
          #       ) do |item|
          #         item.media do
          #           image_tag(
          #             world.page_icon_variant,
          #             class: "size-16 rounded-world-icon",
          #           )
          #         end
          #         item.content(class: "gap-0") do
          #           item.title do
          #             world.name
          #           end
          #           item.description do
          #             world.friendly_id
          #           end
          #         end
          #       end
          #     end
          #   end
          # end
        end
      end
    end
  end
end
