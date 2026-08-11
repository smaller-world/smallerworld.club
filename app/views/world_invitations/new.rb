# typed: strict
# frozen_string_literal: true

class Views::WorldInvitations::New < Views::Base
  # == Initialization ==

  sig { params(invitation: WorldInvitation, previous_url: T.nilable(String)).void }
  def initialize(invitation:, previous_url:)
    super()
    @invitation = invitation
    @previous_url = previous_url
    @world = T.let(invitation.world!, World)
    @recipient = T.let(invitation.recipient!, User)
  end

  # == View ==

  sig { override.void }
  def view_template
    Components::AppLayout(
      page_title: "invite #{@recipient.name} to your world",
    ) do |app_layout|
      app_layout.page_container(class: "max-w-lg flex flex-col gap-6") do
        unless hotwire_native_app?
          button_link_to(
            @previous_url || [ @world, :keys ],
            variant: :secondary,
            icon: "huge/link-backward",
            class: "self-start",
          ) do
            @previous_url ? "back" : "back to your friends"
          end
        end

        div(class: "relative self-center") do
          image_tag(
            @world.page_icon_variant,
            class: "world-icon",
            data: {
              world_icon_size: "sm",
            },
          )
          div(class: "absolute inset-0 flex items-center justify-center") do
            Icon("huge/key-01", class: "size-10 text-white")
          end
        end

        Components::WorldInvitationForm(
          invitation: @invitation,
          previous_url: @previous_url,
        )
      end
    end
  end
end
