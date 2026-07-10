# typed: strict
# frozen_string_literal: true

class Views::WorldInvitations::Edit < Views::Base
  # == Initialization ==

  sig { params(invitation: WorldInvitation).void }
  def initialize(invitation:)
    super()
    @invitation = invitation
    @world = T.let(invitation.world!, World)
    @recipient = T.let(invitation.recipient!, User)
  end

  # == View ==

  sig { override.void }
  def view_template
    Components::AppLayout(page_title: "edit invitation") do |app_layout|
      app_layout.page_container(class: "max-w-lg flex flex-col gap-6") do
        unless hotwire_native_app?
          button_back_to(
            "your friends",
            [ @world, :keys ],
            variant: :secondary,
            class: "self-start",
          )
        end

        Components::Item(
          variant: :muted,
          size: :xs,
          class: "gap-3 pr-3.5",
        ) do |item|
          item.media do
            div(class: "relative") do
              image_tag(
                @world.page_icon_variant,
                class: "world-icon",
                data: { world_icon_size: "xs" },
              )
              div(class: "absolute inset-0 flex items-center justify-center") do
                Icon("huge/key-01", class: "size-6 text-white")
              end
            end
          end
          item.content do |item_content|
            item_content.title do
              "#{@recipient.name}'s invitation"
            end
            item_content.description(class: "text-xs") do
              plain("you invited #{@recipient.name} to your world on ")
              local_time(@world.created_at)
            end
          end
        end

        Components::WorldInvitationForm(invitation: @invitation)
      end
    end
  end
end
