# typed: strict
# frozen_string_literal: true

class Views::WorldInvitations::Edit < Views::Base
  # == Initialization ==

  sig { params(invitation: WorldInvitation).void }
  def initialize(invitation:)
    super()
    @invitation = invitation
    @world = T.let(invitation.world!, World)
  end

  # == View ==

  sig { override.void }
  def view_template
    Components::AppLayout(page_title: "edit invitation") do |layout|
      layout.page_container(class: "max-w-lg space-y-6") do
        unless hotwire_native_app?
          button_back_to("your friends", [ @world, :keys ], variant: :secondary)
        end

        Components::WorldInvitationForm(invitation: @invitation)
      end
    end
  end
end
