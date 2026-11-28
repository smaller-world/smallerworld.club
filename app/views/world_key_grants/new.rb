# typed: strict
# frozen_string_literal: true

class Views::WorldKeyGrants::New < Views::Base
  # == Initialization ==

  sig { params(grant: WorldKeyGrant, return_url: T.nilable(String)).void }
  def initialize(grant:, return_url: nil)
    super()
    @grant = grant
    @return_url = return_url

    @world = T.let(grant.world, World)
  end

  # == View ==

  sig { override.void }
  def view_template
    Components::AppLayout(
      page_title: "add a friend to your world",
      disable_cache: true,
    ) do |app_layout|
      app_layout.with_navigation(class: "max-w-md") do
        if @return_url
          button_link_to("back", @return_url, variant: :secondary, icon: "huge/link-backward")
        else
          button_back_to("your friends", [ @world, :keys ], variant: :secondary)
        end
      end

      app_layout.page_container(class: "max-w-md") do
        Components::WorldKeyGrantForm(grant: @grant)
      end
    end
  end
end
