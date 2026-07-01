# typed: strict
# frozen_string_literal: true

class Views::PostTypes::Edit < Views::Base
  # == Initialization ==

  sig { params(post_type: PostType).void }
  def initialize(post_type:)
    super()
    @post_type = post_type
    @world = T.let(@post_type.world!, World)
  end

  # == View ==

  sig { override.void }
  def view_template
    Components::AppLayout(page_title: "edit post type") do |layout|
      layout.page_container(class: "max-w-lg space-y-6") do
        unless hotwire_native_app?
          button_back_to(@world.name, @world, variant: :secondary)
        end

        div(class: "flex flex-col gap-0.5") do
          Components::PostTypeForm(post_type: @post_type)
          Components::DropdownMenu(
            class: class_names("hidden" => @post_type.default?),
          ) do |menu|
            menu.with_trigger_button(
              variant: :link,
              size: :sm,
              class: "text-muted-foreground",
            ) do
              "delete post type"
            end
            menu.with_content(anchor: :bottom, class: "min-w-auto") do |menu_content|
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
