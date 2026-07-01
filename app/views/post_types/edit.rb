# typed: strict
# frozen_string_literal: true

class Views::PostTypes::Edit < Views::Base
  # == Initialization ==

  sig { params(post_type: PostType).void }
  def initialize(post_type:)
    super()
    @post_type = post_type
  end

  # == View ==

  sig { override.void }
  def view_template
    Components::AppLayout(page_title: "edit post type") do |layout|
      layout.page_container(class: "max-w-lg space-y-6") do
        unless hotwire_native_app?
          world = @post_type.world!
          button_back_to(world.name, world, variant: :secondary)
        end

        div(class: "flex flex-col gap-1") do
          Components::PostTypeForm(post_type: @post_type)
          Components::DropdownMenu() do |menu|
            menu.with_trigger_button(variant: :link, class: "text-muted-foreground") do
              "delete post type"
            end
            menu.with_content(anchor: :bottom, class: "min-w-none") do |menu_content|
              menu_content.label(class: "pt-1.5 pb-0.5 max-w-52 text-center") do
                "are you sure? all posts of this type will be deleted."
              end
              form_with(url: @post_type, method: :delete) do
                menu_content.button_item(
                  type: :submit,
                  variant: :destructive,
                  class: "justify-center",
                ) do
                  Icon("huge/delete-01")
                  span { "really delete" }
                end
              end
            end
          end
        end
      end
    end
  end
end
