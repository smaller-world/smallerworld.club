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
    Components::AppLayout(page_title: "new post type") do |layout|
      layout.page_container(class: "max-w-lg space-y-6") do
        unless hotwire_native_app?
          button_back_to(@world.name, @world, variant: :secondary)
        end

        Components::PostTypeForm(post_type: @post_type)
      end
    end
  end
end
