# typed: strict
# frozen_string_literal: true

class Views::Posts::Edit < Views::Base
  # == Initialization ==

  sig { params(post: Post).void }
  def initialize(post:)
    super()
    @post = post
    @world = T.let(post.world!, World)
  end

  # == View ==

  sig { override.void }
  def view_template
    Components::AppLayout(page_title: "edit post") do |layout|
      layout.page_container(class: "max-w-lg space-y-6") do
        unless hotwire_native_app?
          button_back_to(@world.name, @world, variant: :secondary)
        end

        div(class: "flex flex-col gap-0.5") do
          Components::PostForm(post: @post)
          Components::DropdownMenu() do |dropdown_menu|
            dropdown_menu.with_trigger_button(
              variant: :link,
              size: :sm,
              class: "text-muted-foreground",
            ) do
              "delete post"
            end
            dropdown_menu.with_content(anchor: :bottom) do |menu_content|
              menu_content.label(class: "pt-1.5 pb-0 text-center") do
                "are you sure?"
              end
              form_with(url: @world, method: :delete) do
                menu_content.button_item(
                  type: :submit,
                  variant: :destructive,
                  class: "justify-center",
                  data: {
                    action: "dropdown-menu#preventAutoClose",
                  },
                ) do
                  Icon("huge/delete-01")
                  span { "really delete" }
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
