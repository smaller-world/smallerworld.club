# typed: strict
# frozen_string_literal: true

class Views::WorldKeyGrants::Show < Views::Base
  # == Initialization ==

  sig { params(world: World, grant: String, invitation: WorldInvitation).void }
  def initialize(world:, grant:, invitation: world.invitations.build)
    @world = world
    @grant = grant
    @invitation = invitation
    super()
  end

  # == View ==

  sig { override.void }
  def view_template
    Components::AppLayout(page_title: "you're invited!") do |layout|
      layout.page_container(
        class: "flex-1 max-w-lg flex flex-col items-center justify-center gap-8",
      ) do
        span(class: "text-lg font-semibold") do
          "you've been invited to:"
        end
        div(class: "world-icon-container") do
          image_tag(@world.page_icon_variant, class: "world-icon")
          span(class: "world-icon-label") do
            @world.name
          end
        end

        Components::AcceptWorldKeyGrantForm(
          world: @world,
          grant: @grant,
          invitation: @invitation,
        )
      end
    end
  end
end
