# typed: strict
# frozen_string_literal: true

class Views::PostTypes::Edit < Views::Base
  # == Initialization ==

  sig { params(post_type: PostType, previous_url: T.nilable(String)).void }
  def initialize(post_type:, previous_url:)
    super()
    @post_type = post_type
    @previous_url = previous_url
    @world = T.let(@post_type.world!, World)
  end

  # == View ==

  sig { override.void }
  def view_template
    Components::AppLayout(page_title: "edit post type") do |app_layout|
      app_layout.with_navigation(class: "max-w-md") do
        button_back_to(
          @world.name,
          @previous_url || @world,
          variant: :secondary,
        )
      end

      app_layout.page_container(class: "max-w-md gap-0.5") do
        Components::PostTypeForm(post_type: @post_type, previous_url: @previous_url)
        Components::ConfirmDeleteButton(
          url: @post_type,
          description: "all posts of this type will be deleted.",
          variant: :link,
          class: "self-center text-muted-foreground",
        ) do
          "delete post type"
        end
      end
    end
  end
end
