# typed: strict
# frozen_string_literal: true

class Views::WorldKeyTypes::New < Views::Base
  # == Initialization ==

  sig { params(key_type: WorldKeyType, return_url: T.nilable(String)).void }
  def initialize(key_type:, return_url:)
    super()
    @key_type = key_type
    @return_url = return_url
    @world = T.let(@key_type.world!, World)
  end

  # == View ==

  sig { override.void }
  def view_template
    Components::AppLayout(page_title: "new key type") do |app_layout|
      app_layout.with_navigation(class: "max-w-md") do
        if @return_url
          button_link_to("back", @return_url, variant: :secondary, icon: "huge/link-backward")
        else
          button_back_to("your friends", [ @world, :keys ], variant: :secondary)
        end
      end

      app_layout.page_container(class: "max-w-md") do
        Components::WorldKeyTypeForm(key_type: @key_type, return_url: @return_url)
      end
    end
  end
end
