# typed: strict
# frozen_string_literal: true

class Views::PostTypes::New < Views::Base
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
    Components::AppLayout(page_title: "new post type") do |app_layout|
      app_layout.with_navigation(class: "max-w-md") do
        button_back_to(@world.name, @previous_url || @world, variant: :secondary)
      end

      app_layout.page_container(class: "max-w-md") do
        Components::PostTypeForm(post_type: @post_type, previous_url: @previous_url)
      end
    end
  end
end
