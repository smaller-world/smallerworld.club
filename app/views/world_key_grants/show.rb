# typed: strict
# frozen_string_literal: true

class Views::WorldKeyGrants::Show < Views::Base
  # == Initialization ==

  sig { params(verified_grant: VerifiedWorldKeyGrant, invitation: WorldInvitation).void }
  def initialize(verified_grant:, invitation: verified_grant.world.invitations.build)
    super()
    @verfied_grant = verified_grant
    @invitation = invitation
    @world = T.let(verified_grant.world, World)
  end

  # == View ==

  sig { override.void }
  def view_template
    Components::AppLayout(page_title: "you're invited!") do |app_layout|
      app_layout.page_container(
        class: "flex-1 max-w-md flex flex-col items-center justify-center gap-8",
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
          verified_grant: @verfied_grant,
          invitation: @invitation,
          class: "self-stretch",
        )
      end
    end
  end
end
