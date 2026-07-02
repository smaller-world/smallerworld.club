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
          Components::ConfirmDeleteButton(
            target: @post_type,
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
end
