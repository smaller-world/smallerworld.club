# typed: strict
# frozen_string_literal: true

class Views::PostTypes::New < Views::Base
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
    Components::AppLayout(page_title: "new post type") do |app_layout|
      app_layout.with_navigation(class: "max-w-md") do
        button_back_to(@world.name, [ @world, new_post: 1 ], variant: :secondary)
      end

      app_layout.page_container(class: "max-w-md") do
        Components::PostTypeForm(post_type: @post_type)
      end
    end
  end
end
