# typed: strict
# frozen_string_literal: true

class Views::WorldInvitations::New < Views::Base
  # == Initialization ==

  sig { params(invitation: WorldInvitation).void }
  def initialize(invitation:)
    super()
    @invitation = invitation
  end

  # == View ==

  sig { override.void }
  def view_template
    recipient = @invitation.recipient!
    world = @invitation.world!
    Components::AppLayout(page_title: "invite #{recipient.name} to your world") do |layout|
      layout.page_container(class: "max-w-lg space-y-6") do
        unless hotwire_native_app?
          button_back_to("your friends", [ world, :keys ], variant: :secondary)
        end

        Components::WorldInvitationForm(invitation: @invitation)
      end
    end
  end
end
